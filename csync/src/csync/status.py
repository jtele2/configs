"""Status display functionality."""

from pathlib import Path

import git
from rich.console import Console
from rich.panel import Panel

from csync.config import Config

console = Console()


class StatusDisplay:
    """Displays sync status information."""

    def __init__(self, config: Config):
        self.config = config
        try:
            self.repo = git.Repo(self.config.configs_dir)
        except git.InvalidGitRepositoryError:
            self.repo = None

    def check_sync_status(self):
        """Check current sync status."""
        if not self.repo:
            return "no-repo"

        try:
            self.repo.remotes.origin.fetch()

            local = self.repo.head.commit
            remote = self.repo.remotes.origin.refs[self.config.branch].commit
            base = self.repo.merge_base(local, remote)[0]

            if local == remote:
                return "synced"
            elif local == base:
                return "behind"
            elif remote == base:
                return "ahead"
            else:
                return "diverged"
        except Exception:
            return "error"

    def _get_symlinked_files(self):
        """Get all symlinked files managed by csync."""
        symlinks = []

        # Check standard config symlinks
        standard_symlinks = [
            (Path.home() / ".zshrc", self.config.configs_dir / "zshrc"),
            (Path.home() / ".direnvrc", self.config.configs_dir / "direnvrc"),
        ]

        for link, target in standard_symlinks:
            if link.is_symlink() and link.exists():
                try:
                    resolved = link.resolve()
                    if resolved == target.resolve():
                        symlinks.append((f"~/{link.name}", f"configs/{target.name}"))
                except Exception:
                    pass

        # Check marked files symlinks
        if self.config.marked_files.exists():
            marked_files = [
                f for f in self.config.marked_files.read_text().strip().split("\n") if f
            ]
            for rel_path in marked_files:
                file_path = Path.home() / rel_path
                external_path = self.config.external_dir / rel_path

                if file_path.is_symlink() and file_path.exists():
                    try:
                        resolved = file_path.resolve()
                        if resolved == external_path.resolve():
                            symlinks.append(
                                (f"~/{rel_path}", f"configs/external/{rel_path}")
                            )
                    except Exception:
                        pass

        return symlinks

    def show_status(self):
        """Display comprehensive status information."""
        # Create main status panel
        status_info = []

        # Machine info
        machine_id = self.config.get_machine_id()
        status_info.append("[bold cyan]📍 Machine Info[/bold cyan]")
        status_info.append(f"  Type: {self.config.machine_type}")
        status_info.append(f"  ID: {machine_id}")
        status_info.append(f"  Config Path: {self.config.configs_dir}")
        status_info.append("")

        # Sync status
        status = self.check_sync_status()
        status_info.append("[bold cyan]📊 Sync Status[/bold cyan]")

        status_messages = {
            "synced": "  [green]✓ Synced[/green] - Everything up to date",
            "ahead": "  [yellow]↑ Ahead[/yellow] - Local changes need pushing",
            "behind": "  [cyan]↓ Behind[/cyan] - Remote changes available",
            "diverged": "  [red]⟷ Diverged[/red] - Both local and remote changes",
            "no-repo": "  [red]✗ No repository[/red] - Run setup first",
            "error": "  [red]✗ Error[/red] - Could not determine status",
        }
        status_info.append(status_messages.get(status, "  Unknown status"))

        # Last sync time
        if self.config.last_sync_file.exists():
            last_sync = self.config.last_sync_file.read_text().strip()
            status_info.append(f"  Last sync: {last_sync}")
        else:
            status_info.append("  Last sync: Never")
        status_info.append("")

        # Marked files
        status_info.append("[bold cyan]📁 Marked Files[/bold cyan]")
        marked_count = 0
        if self.config.marked_files.exists():
            marked_files = [
                f for f in self.config.marked_files.read_text().strip().split("\n") if f
            ]
            marked_count = len(marked_files)

        status_info.append(f"  Count: {marked_count} files")

        if marked_count > 0:
            for file in marked_files:
                status_info.append(f"    - {file}")
        status_info.append("")

        # Symlinked files
        status_info.append("[bold cyan]🔗 Symlinked Files[/bold cyan]")
        symlinks = self._get_symlinked_files()
        symlink_count = len(symlinks)
        status_info.append(f"  Count: {symlink_count} symlinks")

        if symlink_count > 0:
            for link_path, target_path in symlinks[:10]:
                status_info.append(f"    {link_path} → {target_path}")
            if symlink_count > 10:
                status_info.append(f"    ... and {symlink_count - 10} more")
        status_info.append("")

        # Backups
        status_info.append("[bold cyan]💾 Backups[/bold cyan]")
        backups = list(self.config.backup_dir.glob("backup-*.tar.gz"))
        backup_count = len(backups)
        status_info.append(f"  Count: {backup_count} backups")

        if backup_count > 0:
            latest = sorted(backups)[-1]
            status_info.append(f"  Latest: {latest.name}")
        status_info.append("")

        # Git status
        if self.repo:
            status_info.append("[bold cyan]🔧 Git Status[/bold cyan]")
            status_info.append(f"  Branch: {self.config.branch}")
            changes = len(self.repo.index.diff(None)) + len(self.repo.untracked_files)
            status_info.append(f"  Uncommitted changes: {changes}")

        # Display in a nice panel
        panel = Panel(
            "\n".join(status_info),
            title="[bold magenta]Config Sync Status[/bold magenta]",
            border_style="cyan",
            padding=(1, 2),
        )
        console.print(panel)
