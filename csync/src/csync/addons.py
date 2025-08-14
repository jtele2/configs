"""Addon and plugin management."""

import os
import subprocess
from pathlib import Path

from rich.console import Console
from rich.prompt import Confirm

from csync.config import Config

console = Console()


class AddonManager:
    """Manages addons and plugin installations."""
    
    def __init__(self, config: Config):
        self.config = config
    
    def setup_addons(self):
        """Install plugins and other addons."""
        console.print("[bold magenta]🎨 Setting up addons and plugins...[/bold magenta]")
        
        # Run setup_plugins.sh if it exists
        setup_script = self.config.configs_dir / "setup_plugins.sh"
        if setup_script.exists():
            console.print("[blue]📦 Installing Oh My Zsh custom plugins...[/blue]")
            try:
                result = subprocess.run(
                    ["bash", str(setup_script)],
                    capture_output=True,
                    text=True,
                    cwd=self.config.configs_dir
                )
                if result.returncode == 0:
                    console.print("[green]✅ Plugins installed successfully[/green]")
                else:
                    console.print(f"[yellow]⚠️  Plugin installation had issues: {result.stderr}[/yellow]")
            except Exception as e:
                console.print(f"[red]❌ Failed to run setup_plugins.sh: {e}[/red]")
        else:
            console.print("[yellow]⚠️  setup_plugins.sh not found[/yellow]")
        
        # Check for Oh My Zsh
        omz_path = Path.home() / ".oh-my-zsh"
        if not omz_path.exists():
            if Confirm.ask("[yellow]💎 Oh My Zsh not found. Would you like to install it?[/yellow]"):
                console.print("[blue]Installing Oh My Zsh...[/blue]")
                try:
                    subprocess.run([
                        "sh", "-c",
                        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)",
                        "", "--unattended"
                    ], check=True)
                    console.print("[green]✅ Oh My Zsh installed[/green]")
                except subprocess.CalledProcessError as e:
                    console.print(f"[red]❌ Failed to install Oh My Zsh: {e}[/red]")
        
        console.print("[green]✅ Addon setup complete![/green]")
        
        # Reload configuration if in zsh
        if os.environ.get("ZSH_VERSION") and (Path.home() / ".zshrc").exists():
            console.print("[blue]🔄 Reloading zsh configuration...[/blue]")
            console.print("[green]✓ Please run 'source ~/.zshrc' to reload[/green]")
        else:
            console.print("[yellow]💡 Restart your shell or run 'source ~/.zshrc' to load changes[/yellow]")