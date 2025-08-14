"""Command-line interface for csync."""

import sys
from pathlib import Path

import click
from rich.console import Console

from csync.addons import AddonManager
from csync.backup import BackupManager
from csync.config import Config
from csync.marked import MarkedFilesManager
from csync.status import StatusDisplay
from csync.symlinks import SymlinkManager
from csync.sync import Syncer

console = Console()


@click.group(invoke_without_command=True)
@click.pass_context
@click.option("--version", is_flag=True, help="Show version and exit")
def cli(ctx, version):
    """🚀 Beautiful config synchronization tool for managing dotfiles across machines."""
    if version:
        from csync import __version__
        console.print(f"[bold cyan]csync version {__version__}[/bold cyan]")
        sys.exit(0)
    
    # If no command provided, run default sync
    if ctx.invoked_subcommand is None:
        sync()


@cli.command()
@click.option("--force-push", is_flag=True, help="Force push local changes (overwrites remote)")
@click.option("--force-pull", is_flag=True, help="Force pull remote changes (overwrites local)")
@click.option("--dry-run", is_flag=True, help="Preview changes without syncing")
@click.option("--background", is_flag=True, help="Run sync quietly in background")
def sync(force_push=False, force_pull=False, dry_run=False, background=False):
    """⚡ Synchronize configurations with remote repository."""
    config = Config()
    
    # Check if configs directory exists
    if not config.configs_dir.exists():
        console.print(f"[red]❌ Config directory not found at {config.configs_dir}[/red]")
        console.print("[yellow]Please clone the repository first:[/yellow]")
        console.print(f"  git clone git@github.com:jtele2/configs.git {config.configs_dir}")
        sys.exit(1)
    
    syncer = Syncer(config)
    syncer.sync(force_push, force_pull, dry_run, background)


@cli.command()
def setup():
    """🔧 Initial setup on new machine."""
    config = Config()
    
    console.print("[bold blue]🔧 Setting up sync environment...[/bold blue]")
    
    # Create directory structure
    config.sync_dir.mkdir(parents=True, exist_ok=True)
    config.backup_dir.mkdir(parents=True, exist_ok=True)
    config.external_dir.mkdir(parents=True, exist_ok=True)
    
    # Get machine ID
    machine_id = config.get_machine_id()
    console.print(f"[green]📍 Machine ID: {machine_id}[/green]")
    
    # Create marked files list if it doesn't exist
    if not config.marked_files.exists():
        config.marked_files.touch()
    
    # Create config symlinks
    console.print("[blue]🔗 Creating config symlinks...[/blue]")
    symlink_mgr = SymlinkManager(config)
    symlink_mgr.create_symlinks(force=True)
    
    # Create zshrc.local if it doesn't exist
    zshrc_local = config.configs_dir / "zshrc.local"
    if not zshrc_local.exists():
        zshrc_local.write_text(f"""# Machine-specific configuration for {machine_id}
# This file is not synced and can contain local customizations

# Example: Work-specific aliases
# alias work-vpn='sudo openconnect vpn.company.com'

# Example: Personal-specific paths  
# export PERSONAL_PROJECTS="$HOME/personal"

# Machine type: {config.machine_type}
# Config path: {config.configs_dir}
""")
        console.print("[green]✅ Created zshrc.local for machine-specific settings[/green]")
    
    # Update .gitignore
    gitignore = config.configs_dir / ".gitignore"
    if gitignore.exists():
        content = gitignore.read_text()
        if ".sync/" not in content:
            gitignore.write_text(content + "\n# Sync system files\n.sync/\n*.local\n")
            console.print("[green]✅ Updated .gitignore[/green]")
    
    # Initialize git if needed
    syncer = Syncer(config)
    
    # Initial status
    config.update_sync_status("")
    
    console.print("[bold green]✅ Setup complete![/bold green]")
    console.print("\n[cyan]Next steps:[/cyan]")
    console.print(f"  1. Review and edit {config.configs_dir}/zshrc.local for machine-specific settings")
    console.print("  2. Run 'csync' to sync with remote")
    console.print("  3. Mark external files with 'csync mark <file>'")


@cli.command()
def status():
    """📊 Show sync status and information."""
    config = Config()
    status_display = StatusDisplay(config)
    status_display.show_status()


@cli.command()
@click.argument("path", type=click.Path())
def mark(path):
    """📌 Mark a file/directory for syncing."""
    config = Config()
    manager = MarkedFilesManager(config)
    manager.mark_file(path)


@cli.command()
@click.argument("path", type=click.Path())
def unmark(path):
    """🚫 Stop syncing a file/directory."""
    config = Config()
    manager = MarkedFilesManager(config)
    manager.unmark_file(path)


@cli.command("list-marked")
def list_marked():
    """📋 List all marked files."""
    config = Config()
    manager = MarkedFilesManager(config)
    manager.list_marked()


@cli.command()
def backup():
    """💾 Create backup only, no sync."""
    config = Config()
    backup_mgr = BackupManager(config)
    backup_mgr.create_backup()


@cli.command()
@click.argument("backup_file", required=False)
def restore(backup_file):
    """♻️ Restore from backup."""
    config = Config()
    backup_mgr = BackupManager(config)
    backup_mgr.restore_backup(backup_file)


@cli.command("list-backups")
def list_backups():
    """📦 List available backups."""
    config = Config()
    backup_mgr = BackupManager(config)
    backup_mgr.list_backups()


@cli.command("setup-addons")
def setup_addons():
    """🎨 Install plugins, completions, and other addons."""
    config = Config()
    addon_mgr = AddonManager(config)
    addon_mgr.setup_addons()


@cli.command("create-symlinks")
@click.option("--force", is_flag=True, help="Replace existing files")
def create_symlinks(force):
    """🔗 Manually create config symlinks."""
    config = Config()
    symlink_mgr = SymlinkManager(config)
    symlink_mgr.create_symlinks(force)


def main():
    """Entry point for the CLI."""
    try:
        cli()
    except KeyboardInterrupt:
        console.print("\n[yellow]Interrupted by user[/yellow]")
        sys.exit(1)
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")
        sys.exit(1)


if __name__ == "__main__":
    main()