"""Core synchronization functionality."""

import tarfile
from datetime import datetime
from pathlib import Path

import git
from rich.console import Console

from csync.config import Config

console = Console()


class Syncer:
    """Handles all synchronization operations."""

    def __init__(self, config: Config):
        self.config = config
        self.repo = None
        self._init_repo()

    def _init_repo(self):
        """Initialize git repository."""
        try:
            self.repo = git.Repo(self.config.configs_dir)
        except git.InvalidGitRepositoryError:
            console.print("[yellow]Not a git repository. Initializing...[/yellow]")
            self.repo = git.Repo.init(self.config.configs_dir)
            self.repo.create_remote("origin", "git@github.com:jtele2/configs.git")
            self.repo.remotes.origin.fetch()
            self.repo.create_head("main", self.repo.remotes.origin.refs.main)
            self.repo.heads.main.checkout()

    def check_network(self) -> bool:
        """Check network connectivity to GitHub."""
        try:
            self.repo.remotes.origin.fetch()
            return True
        except Exception as e:
            console.print(f"[red]❌ Cannot reach remote repository: {e}[/red]")
            self.config.update_sync_status("✗")
            return False

    def create_backup(self) -> bool:
        """Create timestamped backup."""
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

        return True

    def sync(self, force_push=False, force_pull=False, dry_run=False, background=False):
        """Perform full sync operation."""
        if not self.check_network():
            if not background:
                console.print("[red]❌ Network check failed[/red]")
            return False

        self.config.update_sync_status("⚡")

        machine_id = self.config.get_machine_id()
        if not background:
            console.print(f"[blue]🔄 Starting sync from: {machine_id}[/blue]")

        # Create backup
        if not dry_run and not background:
            self.create_backup()

        # Handle uncommitted changes
        if self.repo.is_dirty():
            if not background:
                console.print("[yellow]📝 Uncommitted local changes detected[/yellow]")

            if dry_run:
                console.print("[blue]DRY RUN: Would stash local changes[/blue]")
                for item in self.repo.index.diff(None):
                    console.print(f"  {item.a_path}")
            else:
                stash_msg = f"Auto-stash by sync from {machine_id} at {datetime.now():%Y-%m-%d %H:%M:%S}"
                self.repo.git.stash("push", "-m", stash_msg)
                if not background:
                    console.print("[green]✅ Local changes stashed[/green]")

        # Handle force operations
        if force_push:
            console.print("[yellow]⬆️  Force pushing local changes...[/yellow]")
            if not dry_run:
                self.repo.remotes.origin.push(
                    refspec=f"{self.config.branch}:{self.config.branch}", force=True
                )
                console.print("[green]✅ Force pushed to remote[/green]")
                self.config.update_sync_status("✓")
            return True

        if force_pull:
            console.print("[yellow]⬇️  Force pulling remote changes...[/yellow]")
            if not dry_run:
                self.repo.git.reset("--hard", f"origin/{self.config.branch}")
                console.print("[green]✅ Reset to remote state[/green]")
                self.sync_marked_files()
                self.config.update_sync_status("✓")
            return True

        # Normal sync
        origin = self.repo.remotes.origin
        origin.fetch()

        local_commit = self.repo.head.commit
        remote_commit = origin.refs[self.config.branch].commit

        if local_commit != remote_commit:
            if not background:
                console.print("[yellow]📥 Pulling remote changes...[/yellow]")

            if dry_run:
                console.print("[blue]DRY RUN: Would pull and rebase[/blue]")
            else:
                try:
                    origin.pull(rebase=True)
                    if not background:
                        console.print("[green]✅ Pulled remote changes[/green]")
                except git.GitCommandError:
                    if not background:
                        console.print(
                            "[yellow]⚠️  Rebase failed, attempting merge...[/yellow]"
                        )
                    self.repo.git.rebase("--abort")

                    try:
                        origin.pull(rebase=False)
                    except git.GitCommandError:
                        console.print(
                            "[red]❌ Merge failed. Manual intervention required.[/red]"
                        )
                        console.print(
                            "[yellow]💡 Try: --force-pull or --force-push[/yellow]"
                        )
                        self.config.update_sync_status("✗")
                        return False
        else:
            if not background:
                console.print("[green]✅ Already up to date with remote[/green]")

        # Apply stashed changes
        if "Auto-stash by sync" in self.repo.git.stash("list"):
            if not background:
                console.print("[yellow]📝 Applying stashed changes...[/yellow]")

            if not dry_run:
                try:
                    self.repo.git.stash("pop")
                except git.GitCommandError:
                    console.print("[yellow]⚠️  Conflicts while applying stash[/yellow]")
                    self.config.update_sync_status("✗")
                    return False

        # Sync marked files
        self.sync_marked_files()

        # Commit any changes
        if self.repo.is_dirty():
            if not background:
                console.print("[yellow]💾 Committing local changes...[/yellow]")

            if dry_run:
                console.print("[blue]DRY RUN: Would commit changes[/blue]")
            else:
                # Use git add with --all flag to respect .gitignore
                self.repo.git.add("--all", ".")
                commit_msg = (
                    f"Sync from {machine_id} at {datetime.now():%Y-%m-%d %H:%M:%S}"
                )
                self.repo.index.commit(commit_msg)
                if not background:
                    console.print("[green]✅ Changes committed[/green]")

        # Push to remote
        local_commit = self.repo.head.commit
        remote_commit = origin.refs[self.config.branch].commit

        if local_commit != remote_commit:
            if not background:
                console.print("[yellow]⬆️  Pushing to remote...[/yellow]")

            if not dry_run:
                origin.push()
                if not background:
                    console.print("[green]✅ Pushed to remote[/green]")
                self.config.update_sync_status("✓")
        else:
            self.config.update_sync_status("✓")

        # Update last sync time
        if not dry_run:
            self.config.last_sync_file.write_text(
                datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            )

            if not background:
                # Create/update symlinks
                from csync.symlinks import SymlinkManager

                symlink_mgr = SymlinkManager(self.config)
                symlink_mgr.create_symlinks()

                console.print("[green]✅ Sync completed successfully![/green]")
        else:
            console.print("[blue]✅ Dry run completed[/blue]")

        return True

    def sync_marked_files(self):
        """Sync marked external files."""
        if not self.config.marked_files.exists():
            return

        marked_files = self.config.marked_files.read_text().strip().split("\n")
        if not marked_files or marked_files == [""]:
            return

        console.print("[blue]📂 Syncing marked files...[/blue]")
        synced_count = 0

        for rel_path in marked_files:
            if not rel_path:
                continue

            file_path = Path.home() / rel_path
            external_path = self.config.external_dir / rel_path

            if not external_path.exists():
                console.print(f"  [yellow]⚠ External file missing: {rel_path}[/yellow]")
                continue

            # Create parent directory if needed
            file_path.parent.mkdir(parents=True, exist_ok=True)

            # Create or update symlink
            if (
                not file_path.is_symlink()
                or file_path.resolve() != external_path.resolve()
            ):
                if file_path.exists() or file_path.is_symlink():
                    file_path.unlink()

                file_path.symlink_to(external_path)
                console.print(
                    f"  [green]✓ Linked: {file_path} → {external_path}[/green]"
                )
                synced_count += 1

        if synced_count > 0:
            console.print(f"  [green]✅ Synced {synced_count} marked file(s)[/green]")
        else:
            console.print("  [cyan]ℹ️  All marked files already in sync[/cyan]")
