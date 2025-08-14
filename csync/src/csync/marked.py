"""Management of marked external files for syncing."""

import shutil
from pathlib import Path

import git
from rich.console import Console
from rich.table import Table

from csync.config import Config

console = Console()


class MarkedFilesManager:
    """Manages files marked for synchronization."""
    
    def __init__(self, config: Config):
        self.config = config
        self.repo = git.Repo(self.config.configs_dir)
    
    def mark_file(self, file_path: str):
        """Mark a file for syncing."""
        file_path = Path(file_path).expanduser().resolve()
        
        if not file_path.exists():
            console.print(f"[red]❌ File not found: {file_path}[/red]")
            return False
        
        # Calculate relative path from HOME
        rel_path = str(file_path.relative_to(Path.home()))
        
        # Check if already marked
        marked_files = self._get_marked_files()
        if rel_path in marked_files:
            console.print(f"[yellow]ℹ️  File already marked: {file_path}[/yellow]")
            return True
        
        external_path = self.config.external_dir / rel_path
        external_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Copy file to external directory
        if file_path.is_dir():
            shutil.copytree(file_path, external_path, dirs_exist_ok=True)
        else:
            shutil.copy2(file_path, external_path)
        
        # Create symlink
        if file_path.exists():
            if file_path.is_dir():
                shutil.rmtree(file_path)
            else:
                file_path.unlink()
        
        file_path.symlink_to(external_path)
        
        # Add to marked files list
        marked_files.append(rel_path)
        self._save_marked_files(marked_files)
        
        # Add to git
        self.repo.index.add([str(external_path), str(self.config.marked_files)])
        self.repo.index.commit(f"Mark file for sync: {rel_path}")
        
        console.print(f"[green]✅ Marked for sync: {file_path}[/green]")
        console.print(f"   [cyan]Linked to: {external_path}[/cyan]")
        
        return True
    
    def unmark_file(self, file_path: str):
        """Unmark a file from syncing."""
        file_path = Path(file_path).expanduser().resolve()
        rel_path = str(file_path.relative_to(Path.home()))
        
        marked_files = self._get_marked_files()
        if rel_path not in marked_files:
            console.print(f"[yellow]ℹ️  File not marked: {file_path}[/yellow]")
            return True
        
        external_path = self.config.external_dir / rel_path
        
        # Replace symlink with actual file
        if file_path.is_symlink() and external_path.exists():
            file_path.unlink()
            if external_path.is_dir():
                shutil.copytree(external_path, file_path)
            else:
                shutil.copy2(external_path, file_path)
        
        # Remove from marked files list
        marked_files.remove(rel_path)
        self._save_marked_files(marked_files)
        
        # Remove from git
        try:
            self.repo.index.remove([str(external_path)], r=True)
            self.repo.index.add([str(self.config.marked_files)])
            self.repo.index.commit(f"Unmark file from sync: {rel_path}")
        except git.GitCommandError:
            pass
        
        console.print(f"[green]✅ Unmarked from sync: {file_path}[/green]")
        
        return True
    
    def list_marked(self):
        """List all marked files."""
        marked_files = self._get_marked_files()
        
        if not marked_files:
            console.print("[yellow]No files marked for sync[/yellow]")
            return
        
        table = Table(title="Files Marked for Sync", show_header=True)
        table.add_column("Status", style="cyan", width=8)
        table.add_column("File Path", style="white")
        
        for rel_path in marked_files:
            file_path = Path.home() / rel_path
            if file_path.is_symlink():
                status = "✓"
                style = "green"
            elif file_path.exists():
                status = "⚠"
                style = "yellow"
            else:
                status = "✗"
                style = "red"
            
            table.add_row(f"[{style}]{status}[/{style}]", str(file_path))
        
        console.print(table)
    
    def _get_marked_files(self):
        """Get list of marked files."""
        if not self.config.marked_files.exists():
            return []
        
        content = self.config.marked_files.read_text().strip()
        if not content:
            return []
        
        return [line for line in content.split("\n") if line]
    
    def _save_marked_files(self, marked_files):
        """Save marked files list."""
        self.config.marked_files.write_text("\n".join(marked_files))