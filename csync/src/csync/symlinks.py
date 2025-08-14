"""Symlink management for config files."""

import os
from pathlib import Path

from rich.console import Console

from csync.config import Config

console = Console()


class SymlinkManager:
    """Manages configuration file symlinks."""

    def __init__(self, config: Config):
        self.config = config

    def create_symlinks(self, force=False):
        """Create symlinks for config files."""
        symlink_created = False

        # Define symlinks to create
        symlinks = [
            (self.config.configs_dir / "zshrc", Path.home() / ".zshrc"),
            (self.config.configs_dir / "direnvrc", Path.home() / ".direnvrc"),
        ]

        console.print("[blue]🔗 Updating config symlinks...[/blue]")

        for source, target in symlinks:
            # Skip if source doesn't exist
            if not source.exists():
                continue

            # Check if target already points to source
            if target.is_symlink() and target.resolve() == source.resolve():
                continue

            # Handle existing files
            if target.exists() or target.is_symlink():
                if force:
                    console.print(f"  [yellow]Replacing: {target}[/yellow]")
                    target.unlink()
                else:
                    console.print(
                        f"  [yellow]Skipping: {target} (already exists)[/yellow]"
                    )
                    continue

            # Create symlink
            target.symlink_to(source)
            console.print(f"  [green]✓ Linked: {target} → {source}[/green]")

            # Mark if zshrc was updated
            if target.name == ".zshrc":
                symlink_created = True

        # Reload Oh My Zsh if zshrc was updated and we're in zsh
        if symlink_created and os.environ.get("ZSH_VERSION"):
            console.print("  [blue]🔄 Reloading Oh My Zsh configuration...[/blue]")
            if target.exists():
                # Note: Can't actually source in Python, but we can notify
                console.print(
                    "  [green]✓ Please run 'source ~/.zshrc' to reload[/green]"
                )
