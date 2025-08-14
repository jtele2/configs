"""Backup and restore functionality."""

import tarfile
from datetime import datetime
from pathlib import Path

from rich.console import Console
from rich.prompt import Prompt
from rich.table import Table

from csync.config import Config

console = Console()


class BackupManager:
    """Manages backup and restore operations."""
    
    def __init__(self, config: Config):
        self.config = config
    
    def create_backup(self):
        """Create a backup of current configuration."""
        backup_name = f"backup-{datetime.now():%Y%m%d-%H%M%S}.tar.gz"
        self.config.backup_dir.mkdir(parents=True, exist_ok=True)
        backup_path = self.config.backup_dir / backup_name
        
        console.print(f"[blue]📦 Creating backup: {backup_name}[/blue]")
        
        with tarfile.open(backup_path, "w:gz") as tar:
            for item in self.config.configs_dir.iterdir():
                if item.name not in [".git", ".sync", "node_modules", ".DS_Store"]:
                    if not item.name.endswith(".local"):
                        tar.add(item, arcname=item.name)
        
        # Keep only last 10 backups
        backups = sorted(self.config.backup_dir.glob("backup-*.tar.gz"))
        for old_backup in backups[:-10]:
            old_backup.unlink()
        
        console.print(f"[green]✅ Backup created: {backup_name}[/green]")
        return True
    
    def restore_backup(self, backup_file: str = None):
        """Restore from a backup."""
        if not backup_file:
            # Show available backups
            backups = sorted(self.config.backup_dir.glob("backup-*.tar.gz"), reverse=True)
            
            if not backups:
                console.print("[yellow]No backups found[/yellow]")
                return False
            
            table = Table(title="Available Backups", show_header=True)
            table.add_column("#", style="cyan", width=3)
            table.add_column("Backup File", style="white")
            table.add_column("Size", style="green", width=10)
            table.add_column("Modified", style="yellow")
            
            for idx, backup in enumerate(backups[:10], 1):
                size = f"{backup.stat().st_size / 1024 / 1024:.1f} MB"
                modified = datetime.fromtimestamp(backup.stat().st_mtime).strftime("%Y-%m-%d %H:%M")
                table.add_row(str(idx), backup.name, size, modified)
            
            console.print(table)
            
            choice = Prompt.ask("Select backup number to restore", default="1")
            try:
                backup_idx = int(choice) - 1
                if 0 <= backup_idx < len(backups):
                    backup_path = backups[backup_idx]
                else:
                    console.print("[red]Invalid selection[/red]")
                    return False
            except ValueError:
                console.print("[red]Invalid selection[/red]")
                return False
        else:
            backup_path = self.config.backup_dir / backup_file
            if not backup_path.exists():
                # Try with full name
                backup_path = self.config.backup_dir / f"backup-{backup_file}.tar.gz"
                if not backup_path.exists():
                    console.print(f"[red]❌ Backup file not found: {backup_file}[/red]")
                    return False
        
        console.print(f"[yellow]🔄 Restoring from {backup_path.name}...[/yellow]")
        
        # Create a restore point first
        self.create_backup()
        
        # Extract backup
        with tarfile.open(backup_path, "r:gz") as tar:
            tar.extractall(self.config.configs_dir)
        
        console.print("[green]✅ Restored from backup successfully[/green]")
        return True
    
    def list_backups(self):
        """List available backups."""
        backups = sorted(self.config.backup_dir.glob("backup-*.tar.gz"), reverse=True)
        
        if not backups:
            console.print("[yellow]No backups found[/yellow]")
            return
        
        table = Table(title="Available Backups", show_header=True)
        table.add_column("Backup File", style="cyan")
        table.add_column("Size", style="green", width=10)
        table.add_column("Created", style="yellow")
        
        for backup in backups:
            size = f"{backup.stat().st_size / 1024 / 1024:.1f} MB"
            created = datetime.fromtimestamp(backup.stat().st_mtime).strftime("%Y-%m-%d %H:%M:%S")
            table.add_row(backup.name, size, created)
        
        console.print(table)