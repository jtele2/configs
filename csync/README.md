# csync - Beautiful Config Sync Tool 🚀

A modern, beautiful configuration synchronization tool built with Python, Click, and Rich.

## Features

- 🎨 **Beautiful CLI** - Rich formatting with colors, tables, and progress indicators
- 🔄 **Smart Sync** - Intelligent conflict resolution with rebase/merge strategies
- 📌 **File Marking** - Mark external files for syncing across machines
- 💾 **Automatic Backups** - Timestamped backups with rotation
- 🔗 **Symlink Management** - Automatic creation and management of config symlinks
- 🖥️ **Cross-Platform** - Works on macOS, Linux, and EC2 instances
- ⚡ **Fast & Efficient** - Built with modern Python tools

## Installation

```bash
# Install with uv (recommended)
cd csync
uv sync

# Or install with pip
pip install -e .
```

## Quick Start

```bash
# Initial setup on new machine
csync setup

# Sync configurations
csync

# Check status
csync status

# Mark files for syncing
csync mark ~/.config/nvim
csync list-marked

# Create backup
csync backup

# See all commands
csync --help
```

## Commands

| Command | Description |
|---------|-------------|
| `csync` | Perform normal sync |
| `csync setup` | Initial setup on new machine |
| `csync status` | Show sync status and info |
| `csync mark PATH` | Mark file/directory for syncing |
| `csync unmark PATH` | Stop syncing file/directory |
| `csync list-marked` | List all marked files |
| `csync backup` | Create backup only |
| `csync restore [FILE]` | Restore from backup |
| `csync list-backups` | List available backups |
| `csync setup-addons` | Install plugins and addons |
| `csync create-symlinks` | Manually create config symlinks |

## Sync Options

```bash
# Preview changes without syncing
csync sync --dry-run

# Force push local changes (overwrites remote)
csync sync --force-push

# Force pull remote changes (overwrites local)
csync sync --force-pull

# Run in background (quiet mode)
csync sync --background
```

## Development

```bash
# Format code with ruff
ruff format .

# Lint code
ruff check .

# Run with uv
uv run csync
```

## Architecture

The tool is organized into clean, modular components:

- `config.py` - Configuration and environment detection
- `sync.py` - Core synchronization logic
- `marked.py` - Marked files management
- `symlinks.py` - Symlink creation and management
- `backup.py` - Backup and restore functionality
- `status.py` - Status display with Rich formatting
- `addons.py` - Plugin and addon management
- `cli.py` - Click CLI interface

## License

MIT