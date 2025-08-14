# Config Repository 🚀

Personal configuration files with automatic synchronization across machines using **csync**.

## Quick Setup

```bash
# Clone repository (Mac)
git clone git@github.com:jtele2/configs.git ~/dev/configs

# Clone repository (Linux/EC2)
git clone git@github.com:jtele2/configs.git ~/configs

# Initial setup
cd ~/configs  # or ~/dev/configs on Mac
cd csync && uv sync && cd ..
source csync_alias.sh

# Run setup and sync
csync setup
csync
```

## What's Included

### Zsh Configuration

- **zshrc** - Main Zsh configuration with Oh My Zsh
- **zsh_custom/** - Custom themes, completions, and plugins
- **direnvrc** - direnv configuration
- **setup_plugins.sh** - Plugin installer script

### csync Tool  

A beautiful Python-based config synchronization tool that:

- 🔄 Syncs configurations across Mac, Linux, and EC2
- 📌 Marks external files for syncing (like ~/.claude/)
- 💾 Creates automatic backups before each sync
- 🔗 Manages symlinks for config files
- 🎨 Beautiful CLI with colors and formatting

## Common Commands

```bash
# Sync configurations
csync

# Check status
csync status

# Mark files for syncing across machines
csync mark ~/.config/nvim
csync mark ~/.claude/settings.json

# List marked files
csync list-marked

# Create/restore backups
csync backup
csync restore
csync list-backups

# Install plugins and addons
csync setup-addons

# Manually create config symlinks
csync create-symlinks --force
```

### Sync Options

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

## How It Works

### File Synchronization

- **Repository files** - All files in this git repo sync normally
- **Marked files** - External files can be marked for syncing (stored in `external/`)
- **Local files** - Files ending in `.local` are never synced

### Machine Detection

- **Mac**: Uses `~/dev/configs` path
- **Linux/EC2**: Uses `~/configs` path
- Automatically detects and adapts to your environment

### Marked Files

When you mark a file with `csync mark`:

1. File is copied to `external/` directory in the repo
2. Original location gets a symlink to the repo copy
3. File syncs across all your machines
4. Symlinks are recreated on each machine

## Examples

### Daily Workflow

```bash
# Morning - sync latest changes
csync

# Make changes to configs...

# Evening - sync changes back
csync
```

### Managing External Configs

```bash
# Mark your vim config for syncing
csync mark ~/.vimrc

# Mark entire directories
csync mark ~/.config/nvim

# Stop syncing something
csync unmark ~/.vimrc
```

### Handling Conflicts

```bash
# Preview changes
csync sync --dry-run

# Force your local changes
csync sync --force-push

# Accept remote changes
csync sync --force-pull
```

## Troubleshooting

**csync command not found**

```bash
source ~/configs/csync_alias.sh  # or add to .zshrc
```

**Merge conflicts**

```bash
csync sync --force-pull   # Accept remote
# OR
csync sync --force-push   # Keep local
```

**Missing dependencies**

```bash
cd ~/configs/csync
uv sync
```

## Development

The csync tool is built with:

- **Python** with Click and Rich libraries  
- **GitPython** for git operations
- **PyYAML** for configuration files
- **uv** for package management
- **ruff** for linting and formatting

### Architecture

- `config.py` - Configuration and environment detection
- `sync.py` - Core synchronization logic
- `marked.py` - Marked files management
- `symlinks.py` - Symlink creation and management
- `backup.py` - Backup and restore functionality
- `status.py` - Status display with Rich formatting
- `addons.py` - Plugin and addon management
- `cli.py` - Click CLI interface

### Development Commands

```bash
# Format code with ruff
cd csync && ruff format .

# Lint code
ruff check .

# Run with uv
uv run csync
```

## License

MIT
