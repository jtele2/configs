# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

csync is a Python-based configuration synchronization tool that manages dotfiles across Mac, Linux, and EC2 instances. It uses git for version control and creates symlinks to manage configuration files.

## Development Commands

### Running csync
```bash
# Run directly with uv (from csync directory)
uv run csync [command]

# After sourcing alias (from anywhere)
source ~/dev/configs/csync_alias.sh  # or ~/configs/csync_alias.sh on Linux
csync [command]
```

### Code Quality
```bash
# Format code with ruff
uv run ruff format src/

# Lint code
uv run ruff check src/

# Fix linting issues
uv run ruff check --fix src/
```

### Dependency Management
```bash
# Install dependencies
uv sync

# Add new dependency
uv add <package>

# Add dev dependency
uv add --dev <package>
```

## Architecture

### Core Components

**Environment Detection** (`config.py`)
- Automatically detects machine type (Mac/Linux/EC2)
- Mac uses `~/dev/configs`, Linux/EC2 uses `~/configs`
- Machine ID stored in `.sync/machine-id`

**Synchronization Flow** (`sync.py`)
1. Creates backup before sync
2. Fetches latest from remote
3. Handles merge conflicts with force options
4. Updates symlinks after sync
5. Records sync timestamp

**Marked Files System** (`marked.py`)
- External files are copied to `external/` directory
- Original location replaced with symlink
- Tracked in `.marked-files` (line-separated paths relative to home)
- Symlinks recreated on each machine during sync

**Symlink Management** (`symlinks.py`)
- Standard symlinks: `.zshrc` → `configs/zshrc`, `.direnvrc` → `configs/direnvrc`
- Marked file symlinks: `~/path/to/file` → `configs/external/path/to/file`

### Git Integration

- Uses GitPython library for all git operations
- Automatic commits for marking/unmarking files
- Force push/pull options for conflict resolution
- Branch specified via `SYNC_BRANCH` env var (default: main)

### Plugin Management

**Oh My Zsh Plugins**
- `setup_plugins.sh` clones external plugins to `zsh_custom/plugins/`
- `autoswitch_virtualenv` excluded from git via `.gitignore`
- Plugins reinstalled via `csync setup-addons` after pulls

## Important Patterns

### File Exclusions
- `.local` suffix: Machine-specific files never synced
- `.sync/`: Contains machine state and backups
- Plugin directories in `.gitignore` to avoid nested `.git` issues

### CLI Structure
- Uses Click framework with command groups
- Default command (no args) runs sync
- Rich library for colored terminal output
- All commands return appropriate exit codes

### Status Display
- Shows machine info, sync status, marked files, symlinks, backups
- Symlinks section added via `_get_symlinked_files()` method
- Displays up to 10 symlinks with overflow indicator

## Common Tasks

### Adding New Commands
1. Add command function to `cli.py` with `@cli.command()` decorator
2. Implement logic in appropriate module
3. Use `console.print()` for colored output

### Modifying Sync Behavior
- Core logic in `Syncer.sync()` method
- Backup → Fetch → Merge/Rebase → Push → Update Symlinks
- Force options bypass normal merge conflict handling

### Updating Status Display
- Modify `StatusDisplay.show_status()` in `status.py`
- Add new sections before Git Status section
- Use Rich formatting: `[bold cyan]`, `[green]`, etc.

## File Paths

### Config Locations
- Mac: `~/dev/configs/`
- Linux/EC2: `~/configs/`
- Sync state: `.sync/` directory
- External files: `external/` directory
- Marked files list: `.marked-files`

### Python Package Structure
```
csync/
├── pyproject.toml       # Package config, dependencies, ruff settings
├── uv.lock             # Locked dependencies
└── src/csync/
    ├── __init__.py
    ├── cli.py          # Click CLI entry point
    ├── config.py       # Environment detection and paths
    ├── sync.py         # Core sync logic
    ├── marked.py       # Marked files management
    ├── symlinks.py     # Symlink creation
    ├── backup.py       # Backup/restore functionality
    ├── status.py       # Status display with symlinks
    └── addons.py       # Plugin installation
```