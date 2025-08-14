"""Configuration management for csync."""

import os
import platform
from pathlib import Path

from rich.console import Console

console = Console()


class Config:
    """Manages configuration paths and environment detection."""
    
    def __init__(self):
        self.detect_environment()
        self.setup_paths()
    
    def detect_environment(self):
        """Detect machine type and set configs directory."""
        # Check if we're on EC2
        if Path("/etc/ec2-metadata").exists() or (
            Path("/sys/hypervisor/uuid").exists() 
            and Path("/sys/hypervisor/uuid").read_text()[:3] == "ec2"
        ):
            self.configs_dir = Path.home() / "configs"
            self.machine_type = "ec2"
        elif platform.system() == "Darwin":
            self.configs_dir = Path.home() / "dev" / "configs"
            self.machine_type = "mac"
        else:
            # Fallback for other Linux systems
            self.configs_dir = Path.home() / "configs"
            self.machine_type = "linux"
    
    def setup_paths(self):
        """Set up all configuration paths."""
        self.sync_dir = self.configs_dir / ".sync"
        self.backup_dir = self.sync_dir / "backups"
        self.machine_id_file = self.sync_dir / "machine-id"
        self.last_sync_file = self.sync_dir / "last-sync"
        self.sync_status_file = self.sync_dir / "sync-status"
        self.marked_files = self.configs_dir / ".marked-files"
        self.external_dir = self.configs_dir / "external"
        self.branch = os.environ.get("SYNC_BRANCH", "main")
    
    def get_machine_id(self):
        """Get or create machine identifier."""
        self.sync_dir.mkdir(parents=True, exist_ok=True)
        
        if not self.machine_id_file.exists():
            hostname = platform.node().split(".")[0]
            machine_id = f"{os.environ['USER']}@{hostname}-{self.machine_type}"
            self.machine_id_file.write_text(machine_id)
        
        return self.machine_id_file.read_text().strip()
    
    def update_sync_status(self, status: str):
        """Update sync status for shell prompt."""
        self.sync_dir.mkdir(parents=True, exist_ok=True)
        self.sync_status_file.write_text(status)