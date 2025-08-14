# Config Sync System

A Git-based configuration synchronization tool for managing dotfiles and configurations across multiple machines (Mac and Linux/EC2).

## Features

- **Automatic conflict resolution** - Intelligent handling of merge conflicts with fallback strategies
- **Machine-specific customization** - Support for `.local` files that aren't synced
- **Selective file syncing** - Mark external files outside the repo for synchronization
- **Automatic backups** - Creates timestamped backups before each sync operation
- **Shell prompt integration** - Visual sync status indicator in your prompt
- **Cross-platform support** - Automatically detects and adapts to Mac/Linux environments

## Quick Start

```bash
# Clone the repository
git clone git@github.com:jtele2/configs.git ~/configs  # On EC2/Linux
git clone git@github.com:jtele2/configs.git ~/dev/configs  # On Mac

# Run initial setup
./sync.sh --setup

# Perform first sync
./sync.sh
```

## Installation

### Prerequisites

- Git installed and configured
- SSH key set up for GitHub access
- Bash shell (zsh compatible)

### Setup

1. **Clone the repository** to the appropriate location:
   - Mac: `~/dev/configs`
   - Linux/EC2: `~/configs`

2. **Run the setup command**:
   ```bash
   cd ~/configs  # or ~/dev/configs on Mac
   ./sync.sh --setup
   ```

3. **Configure machine-specific settings** in `zshrc.local` (created automatically)

## Usage

### Basic Commands

```bash
# Perform normal sync
./sync.sh

# Show current status
./sync.sh --status

# Preview changes without syncing
./sync.sh --dry-run
```

### Managing External Files

Mark files outside the repository for synchronization:

```bash
# Mark a file or directory for syncing
./sync.sh --mark ~/.config/some-app/config

# Stop syncing a file
./sync.sh --unmark ~/.config/some-app/config

# List all marked files
./sync.sh --list-marked
```

### Conflict Resolution

```bash
# Force push local changes (overwrites remote)
./sync.sh --force-push

# Force pull remote changes (overwrites local)
./sync.sh --force-pull
```

### Backup and Recovery

```bash
# Create backup only (no sync)
./sync.sh --backup

# List available backups
./sync.sh --list-backups

# Restore from backup (interactive)
./sync.sh --restore

# Restore specific backup
./sync.sh --restore backup-20240814-120000.tar.gz
```

## Complete Command Reference

| Command | Description |
|---------|-------------|
| `./sync.sh` | Perform normal sync |
| `./sync.sh --setup` | Initial setup on new machine |
| `./sync.sh --status` | Show sync status and info |
| `./sync.sh --help` | Display help message |
| `./sync.sh --mark PATH` | Mark file/directory for syncing |
| `./sync.sh --unmark PATH` | Stop syncing file/directory |
| `./sync.sh --list-marked` | List all marked files |
| `./sync.sh --dry-run` | Preview changes without syncing |
| `./sync.sh --force-push` | Force push (overwrites remote) |
| `./sync.sh --force-pull` | Force pull (overwrites local) |
| `./sync.sh --backup` | Create backup only |
| `./sync.sh --restore [FILE]` | Restore from backup |
| `./sync.sh --list-backups` | List available backups |
| `./sync.sh --background` | Run sync quietly in background |

## How It Works

### File Synchronization

1. **Repository files** - All files in the git repository are synced normally
2. **Marked external files** - Files outside the repo can be marked for syncing
3. **Local-only files** - Files with `.local` suffix are never synced

### Conflict Resolution

The sync system uses intelligent conflict resolution:

1. **Rebase first** - Attempts to rebase local changes onto remote
2. **Merge fallback** - Falls back to merge if rebase fails
3. **Manual override** - Use `--force-push` or `--force-pull` when needed

### Automatic Backups

- Creates timestamped backups before each sync
- Keeps the last 10 backups automatically
- Stores backups in `.sync/backups/`
- Includes both repo and marked external files

## Shell Integration

### Prompt Status Indicator

The sync system can display status in your shell prompt:

| Icon | Status | Meaning |
|------|--------|----------|
| ✓ | Synced | Everything up to date |
| ↑ | Ahead | Local changes need pushing |
| ↓ | Behind | Remote changes available |
| ⚡ | Syncing | Sync in progress |
| ✗ | Error | Sync failed or conflicts |

### Automatic Background Sync

Add to your `.zshrc` for automatic syncing:

```bash
# Auto-sync on shell startup
if [[ -d "$HOME/dev/configs" ]]; then
    (cd "$HOME/dev/configs" && ./sync.sh --background &>/dev/null &)
elif [[ -d "$HOME/configs" ]]; then
    (cd "$HOME/configs" && ./sync.sh --background &>/dev/null &)
fi
```

### Useful Aliases

```bash
alias sync-configs='cd $([ -d "$HOME/dev/configs" ] && echo "$HOME/dev/configs" || echo "$HOME/configs") && ./sync.sh'
alias sync-status='cd $([ -d "$HOME/dev/configs" ] && echo "$HOME/dev/configs" || echo "$HOME/configs") && ./sync.sh --status'
```

## Directory Structure

```text
~/configs/                    # Root directory (~/dev/configs on Mac)
├── .sync/                    # Sync metadata (not synced)
│   ├── machine-id           # Unique machine identifier
│   ├── last-sync            # Last sync timestamp
│   ├── sync-status          # Current status for prompt
│   ├── marked-files.txt     # List of external files
│   └── backups/             # Automatic backups
├── external/                 # Marked external files
├── sync.sh                   # This sync script
├── zshrc                     # Main zsh config
├── zshrc.local              # Machine-specific config (not synced)
└── [other configs]          # Your configuration files
```

## Machine-Specific Configuration

The system automatically detects your environment:

- **Mac**: Uses `~/dev/configs` path
- **Linux/EC2**: Uses `~/configs` path

Machine-specific settings go in `zshrc.local`, which is:
- Created automatically during setup
- Never synced between machines
- Sourced by the main `zshrc` file

## Security Notes

- Each machine uses its own SSH key
- Never mark files containing secrets/passwords
- Keep your GitHub repository private
- Backups are stored locally and not encrypted

## Troubleshooting

### Common Issues

#### Config directory not found

- Clone the repository first: `git clone git@github.com:jtele2/configs.git ~/configs`

#### Cannot reach remote repository

- Check your network connection
- Verify SSH key is set up: `ssh -T git@github.com`

#### Merge failed - Manual intervention required

- Use `--force-pull` to accept remote changes
- Use `--force-push` to keep local changes
- Or manually resolve conflicts in the repository

#### Symlink issues with marked files

- Check if the file still exists
- Try unmarking and re-marking the file

### Getting Help

```bash
# Show help message
./sync.sh --help

# Check current status
./sync.sh --status

# Preview changes without syncing
./sync.sh --dry-run
```

## Examples

### Initial Setup on New Machine

```bash
# Clone the repository
git clone git@github.com:jtele2/configs.git ~/configs

# Run setup
cd ~/configs
./sync.sh --setup

# Edit machine-specific settings
vim zshrc.local

# Perform first sync
./sync.sh
```

### Daily Workflow

```bash
# Check status before working
./sync.sh --status

# Sync latest changes
./sync.sh

# Make your changes...

# Sync changes back
./sync.sh
```

### Managing External Configs

```bash
# Mark your vim config for syncing
./sync.sh --mark ~/.vimrc

# Mark entire config directory
./sync.sh --mark ~/.config/nvim

# List what's being synced
./sync.sh --list-marked

# Stop syncing something
./sync.sh --unmark ~/.vimrc
```

### Handling Conflicts

```bash
# Preview what would happen
./sync.sh --dry-run

# If conflicts exist, choose strategy:
# Keep local changes
./sync.sh --force-push

# OR keep remote changes
./sync.sh --force-pull
```

## License

MIT License - Feel free to adapt this for your own use.

## Author

Created for managing dotfiles across multiple development environments.
