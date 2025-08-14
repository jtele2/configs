# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal configuration repository with automatic cross-machine synchronization using **csync** - a Python-based dotfile manager that supports Mac, Linux, and EC2 environments.

## Quick Commands

### Sync Operations

```bash
# Standard sync
csync

# Preview changes without syncing
csync sync --dry-run

# Force push local changes (overwrites remote)
csync sync --force-push

# Force pull remote changes (overwrites local)
csync sync --force-pull

# Run in background (quiet mode)
csync sync --background
```

### File Management

```bash
# Mark external files for syncing
csync mark ~/.vimrc
csync mark ~/.config/nvim

# List marked files
csync list-marked

# Unmark files
csync unmark ~/.vimrc

# Check status
csync status
```

### Backup Operations

```bash
# Create backup
csync backup

# Restore from backup
csync restore

# List available backups
csync list-backups
```

### Setup & Maintenance

```bash
# Initial setup
csync setup

# Install Oh My Zsh plugins
csync setup-addons
./setup_plugins.sh

# Create/recreate symlinks
csync create-symlinks --force
```

## Development Commands

### Running csync

```bash
# From csync directory with uv
cd csync && uv run csync [command]

# Using alias (after sourcing)
source csync_alias.sh
csync [command]
```

### Code Quality

```bash
# Format code
cd csync && ruff format src/

# Lint code
ruff check src/

# Fix linting issues
ruff check --fix src/

# Run tests
./run_tests.sh
uv run pytest tests/ -v
```

### Dependency Management

```bash
# Install dependencies
cd csync && uv sync

# Install with dev dependencies
uv sync --dev

# Add new dependency
uv add <package>

# Add dev dependency
uv add --dev <package>
```

## Architecture

### Repository Structure

```text
configs/
├── csync/                  # Python sync tool
│   ├── src/csync/         # Source code
│   │   ├── cli.py         # Click CLI interface
│   │   ├── config.py      # Environment detection
│   │   ├── sync.py        # Core sync logic
│   │   ├── marked.py      # External file management
│   │   ├── symlinks.py    # Symlink operations
│   │   ├── backup.py      # Backup/restore
│   │   ├── status.py      # Status display
│   │   └── addons.py      # Plugin management
│   ├── tests/             # Test suite
│   └── pyproject.toml     # Package config
├── external/              # Marked external files
├── zsh_custom/           # Oh My Zsh customizations
│   ├── themes/
│   ├── plugins/
│   └── completions/
├── zshrc                 # Main Zsh config
├── direnvrc             # direnv config
└── .sync/               # Sync state and backups
```

### Key Components

**Environment Detection**

- Mac: Uses `~/dev/configs` path
- Linux/EC2: Uses `~/configs` path
- Machine ID stored in `.sync/machine-id`

**Synchronization Flow**

1. Create backup before sync
2. Fetch latest from remote
3. Handle merge conflicts (with force options)
4. Update symlinks after sync
5. Record sync timestamp

**Marked Files System**

- External files copied to `external/` directory
- Original location replaced with symlink
- Tracked in `.marked-files`
- Symlinks recreated on each machine

**Git Integration**

- Uses GitPython library
- Respects `.gitignore` via `git add --all`
- Never commits: `__pycache__/`, `.local` files, `.git/` internals
- Automatic commits for mark/unmark operations

## Testing

### Run Full Test Suite

```bash
cd csync
./run_tests.sh
```

### Run Specific Tests

```bash
# All tests
uv run pytest tests/ -v

# Specific test file
uv run pytest tests/test_gitignore_compliance.py -v

# With coverage
uv run pytest --cov=csync tests/
```

## Important Patterns

### File Exclusions

- `.local` suffix: Machine-specific, never synced
- `__pycache__/`: Python cache, ignored by git
- `.sync/`: Machine state and backups
- Plugin directories: Managed by `setup_plugins.sh`

### CLI Structure

- Click framework with command groups
- Default command (no args) runs sync
- Rich library for colored output
- All commands return appropriate exit codes

### Git Safety

- **NEVER** use `repo.index.add(".")` - bypasses .gitignore
- **ALWAYS** use `repo.git.add("--all", ".")` - respects .gitignore
- Runtime checks warn about staged ignored files
- Comprehensive test suite validates gitignore compliance

## Adding New Features

### New CLI Command

1. Add command function to `cli.py` with `@cli.command()`
2. Implement logic in appropriate module
3. Use `console.print()` for colored output
4. Add tests in `tests/` directory

### Modifying Sync Behavior

- Core logic in `Syncer.sync()` method
- Flow: Backup → Fetch → Merge → Push → Update Symlinks
- Force options bypass normal merge handling

## Troubleshooting

### Common Issues

```bash
# csync command not found
source ~/configs/csync_alias.sh

# Merge conflicts
csync sync --force-pull   # Accept remote
csync sync --force-push   # Keep local

# Missing dependencies
cd ~/configs/csync && uv sync

# Plugin installation issues
./setup_plugins.sh
csync setup-addons
```

### Verify Git Ignore Protection

```bash
# Run protection tests
cd csync && ./run_tests.sh

# Manual check
git check-ignore __pycache__/
git check-ignore settings.local.json
```
