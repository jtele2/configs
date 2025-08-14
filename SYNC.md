# Config Sync System Design

This document outlines the design for a Git-based configuration sync system across three machines: work Mac, personal Mac, and EC2 instance, with support for selective file syncing through a marking system.

## System Overview

The sync system uses Git as the backbone with:
- Automatic conflict resolution
- Machine-specific customization support
- Selective file syncing via marking system
- Automatic backups before each sync
- Both repository files and marked external files
- Shell prompt sync status indicator
- Support for different config paths per machine

## Architecture

### Directory Structure

**Mac (Work & Personal):**
```
~/dev/configs/                  # Main repo on Mac machines
├── .sync/                      # Sync metadata directory
│   ├── machine-id              # Unique machine identifier
│   ├── last-sync               # Timestamp of last successful sync
│   ├── sync-status             # Current sync status for prompt
│   ├── marked-files.txt        # List of external files to sync
│   └── backups/                # Automatic backups before sync
├── .gitignore                  # Excludes machine-specific files
├── sync.sh                     # Main sync script (to be enhanced)
├── zshrc                       # Main zsh config (in repo)
├── zshrc.local                 # Machine-specific config (not synced)
└── [other repo configs]        # Other config files in repo
```

**EC2 Instance:**
```
~/configs/                      # Main repo on EC2 (different path!)
├── [same structure as above]
```

**External marked files:**
```
~/                              # External marked files
├── .config/some-app/config     # Example external file marked for sync
└── .tool/settings.json         # Another marked file
```

### Machine Detection

The system auto-detects the environment and config path:
```bash
# Detect if we're on EC2 or Mac
if [[ -f /etc/ec2-metadata ]]; then
    CONFIGS_DIR="$HOME/configs"
    MACHINE_TYPE="ec2"
elif [[ "$(uname)" == "Darwin" ]]; then
    CONFIGS_DIR="$HOME/dev/configs"
    MACHINE_TYPE="mac"
fi

# Machine ID includes type for clarity
MACHINE_ID="${USER}@$(hostname -s)-${MACHINE_TYPE}"
```

### File Sync Categories

1. **Repository Files**: All files tracked in the configs git repo
2. **Marked External Files**: Files outside the repo explicitly marked for syncing
3. **Local-Only Files**: Files with `.local` suffix or in .gitignore

## Core Features

### 1. File Marking System

The marking system allows syncing files that live outside the repository:

**Design Approach:**
- Maintain a `.sync/marked-files.txt` manifest of external files to sync
- Store copies of marked files in `.sync/external-files/` (gitignored locally)
- Track the actual synced versions in a separate `external/` directory in the repo
- Create symlinks from original locations to the synced copies

**Mark Command Flow:**
1. User runs: `sync.sh --mark ~/.config/app/config`
2. Script adds path to `.sync/marked-files.txt`
3. Copies file to `~/configs/external/.config/app/config` (preserving path structure)
4. Creates symlink from original location to the repo copy
5. Commits the file to git

**Unmark Command Flow:**
1. User runs: `sync.sh --unmark ~/.config/app/config`
2. Script removes path from `.sync/marked-files.txt`
3. Replaces symlink with actual file copy
4. Removes file from `external/` directory in repo

### 2. Sync Operations

**Normal Sync Flow:**
1. Check network connectivity to GitHub
2. Create backup of current state
3. Stash any uncommitted changes
4. Pull and rebase from remote
5. Apply stashed changes
6. Sync marked external files
7. Commit any changes
8. Push to remote

**Conflict Resolution Priority:**
1. Try rebase first (keeps linear history)
2. Fall back to merge if rebase fails
3. Offer force options (--force-push or --force-pull) for manual override

### 3. Machine-Specific Customization

**Approach:**
- Use `.local` suffix for machine-specific files (e.g., `zshrc.local`)
- Main configs source their `.local` variants if they exist
- Machine ID based on `${USER}@$(hostname -s)`
- Conditional logic in configs based on machine ID

### 4. Backup System

**Strategy:**
- Create timestamped tar.gz before each sync
- Include both repo files and marked external files
- Exclude .git, .sync, and *.local files
- Keep last 10 backups with automatic rotation
- Store in `.sync/backups/`

## Command Interface

### Basic Commands
```bash
./sync.sh                    # Normal sync
./sync.sh --setup            # Initial setup on new machine
./sync.sh --status           # Show sync status and marked files
```

### File Marking
```bash
./sync.sh --mark PATH        # Mark a file/directory for syncing
./sync.sh --unmark PATH      # Stop syncing a file/directory
./sync.sh --list-marked      # List all marked files
```

### Sync Control
```bash
./sync.sh --dry-run          # Preview what would happen
./sync.sh --force-push       # Force local → remote
./sync.sh --force-pull       # Force remote → local
./sync.sh --backup-only      # Just create backup, no sync
```

### Recovery
```bash
./sync.sh --restore          # Interactive restore from backup
./sync.sh --restore DATE     # Restore specific backup
```

## Implementation Plan

### Phase 1: Core Sync Enhancement
- [ ] Enhance existing sync.sh with better conflict resolution
- [ ] Add dry-run mode for safety
- [ ] Implement force-push and force-pull options
- [ ] Add comprehensive logging with colors
- [ ] Create setup function for new machines

### Phase 2: File Marking System
- [ ] Implement mark/unmark commands
- [ ] Create manifest management for marked files
- [ ] Add symlink creation and management
- [ ] Implement external file sync logic
- [ ] Add list-marked command

### Phase 3: Backup and Recovery
- [ ] Enhance backup to include marked files
- [ ] Implement backup rotation (keep last N)
- [ ] Add restore functionality
- [ ] Create backup-only mode

### Phase 4: Status and Monitoring
- [ ] Add status command showing:
  - Current machine ID
  - Last sync time
  - Marked files status
  - Pending changes
- [ ] Add conflict detection warnings
- [ ] Implement sync history tracking

### Phase 5: Automation & UI
- [ ] Add to .zshrc for background sync
- [ ] Add sync status indicator to shell prompt
- [ ] Create sync status function for prompt
- [ ] Test on all three machines

## Shell Prompt Integration

### Sync Status Indicator

Add a sync status indicator to the custom-bira.zsh-theme prompt:

**Status Icons:**
- `✓` - Synced (green): Everything up to date
- `↑` - Pending push (yellow): Local changes need pushing
- `↓` - Pending pull (cyan): Remote changes available
- `⚡` - Syncing (blue): Sync in progress
- `✗` - Error/Conflict (red): Sync failed or conflicts exist
- ` ` - No icon if sync disabled or not in configs repo

**Implementation Approach:**
1. Create a `sync_status()` function in sync.sh that outputs current status
2. Write status to `.sync/sync-status` file for fast prompt access
3. Add status check to custom-bira.zsh-theme
4. Update status file during sync operations

**Prompt Integration:**
```bash
# In custom-bira.zsh-theme
function sync_indicator() {
    local sync_file="$HOME/dev/configs/.sync/sync-status"
    # On EC2, check ~/configs instead
    [[ -f /etc/ec2-metadata ]] && sync_file="$HOME/configs/.sync/sync-status"
    
    if [[ -f "$sync_file" ]]; then
        cat "$sync_file"
    fi
}

# Add to PROMPT line
local sync_status='$(sync_indicator)'
PROMPT="╭─$(nix_indicator)${sync_status}${current_dir}..."
```

### Background Sync in .zshrc

**Auto-sync Strategy:**
```bash
# In zshrc
# Run sync in background on shell startup
if [[ -d "$HOME/dev/configs" ]]; then
    (cd "$HOME/dev/configs" && ./sync.sh --background &>/dev/null &)
elif [[ -d "$HOME/configs" ]]; then
    (cd "$HOME/configs" && ./sync.sh --background &>/dev/null &)
fi

# Alias for manual sync
alias sync-configs='cd $([ -d "$HOME/dev/configs" ] && echo "$HOME/dev/configs" || echo "$HOME/configs") && ./sync.sh'
alias sync-status='cd $([ -d "$HOME/dev/configs" ] && echo "$HOME/dev/configs" || echo "$HOME/configs") && ./sync.sh --status'
```

## Technical Decisions

### Why Symlinks for Marked Files?
- Preserves original file locations expected by applications
- Changes immediately reflected without needing sync
- Easy to see what's managed (symlink indicator)
- Simple to revert (replace symlink with file)

### Why Separate external/ Directory?
- Keeps repository organized
- Preserves original path structure
- Avoids polluting repo root with random files
- Makes it clear what's external vs native to configs repo

### Why Different Paths on Mac vs EC2?
- Mac: `~/dev/configs` keeps all dev work organized in ~/dev
- EC2: `~/configs` follows standard dotfile location
- Auto-detection prevents configuration errors

### Error Handling Strategy
- Never lose data (backup before operations)
- Fail loudly and clearly (colored error messages)
- Provide recovery suggestions
- Default to manual intervention over data loss

## Security Considerations

1. **SSH Key Management**: Each machine uses its own SSH key
2. **Sensitive Files**: Never mark files containing secrets/passwords
3. **Private Repository**: Ensure GitHub repo remains private
4. **Backup Encryption**: Consider encrypting backups (future enhancement)

## Testing Strategy

### Manual Test Cases
1. Normal sync with no conflicts
2. Sync with merge conflicts
3. Mark and sync external file
4. Restore from backup
5. Force push/pull operations
6. Network failure handling
7. Setup on fresh machine

### Edge Cases to Test
- Simultaneous edits on both machines
- Marking already-symlinked files
- Unmarking deleted files
- Syncing with dirty working directory
- Large file handling
- Binary file conflicts

## Future Enhancements

1. **Selective Sync**: Choose which marked files to sync
2. **Sync Profiles**: Different sets of files for different contexts
3. **Encryption**: Encrypted storage for sensitive configs
4. **Diff Viewer**: Show changes before syncing
5. **Sync Hooks**: Pre/post sync scripts for custom logic
6. **Multi-Machine**: Support for 3+ machines
7. **Partial Restores**: Restore individual files from backup

## Development TODO List

### Immediate Tasks
- [ ] Review and enhance existing sync.sh structure
- [ ] Add proper argument parsing with getopts
- [ ] Implement machine detection (Mac vs EC2)
- [ ] Handle different config paths (~/dev/configs vs ~/configs)
- [ ] Implement machine ID management with type suffix
- [ ] Add .gitignore entries for .sync/ and *.local

### Core Sync Tasks  
- [ ] Implement stash/unstash logic
- [ ] Add rebase-first, merge-fallback strategy
- [ ] Create force-push and force-pull functions
- [ ] Add dry-run mode throughout
- [ ] Implement proper exit codes
- [ ] Add --background mode for .zshrc

### Marking System Tasks
- [ ] Create mark_file() function
- [ ] Create unmark_file() function
- [ ] Implement manifest file management
- [ ] Add symlink utilities
- [ ] Create external/ directory structure

### Backup Tasks
- [ ] Enhance backup function with marked files
- [ ] Implement rotation logic
- [ ] Create restore function
- [ ] Add backup listing

### Shell Prompt Integration
- [ ] Create sync_status() function
- [ ] Implement .sync/sync-status file updates
- [ ] Add sync_indicator() to custom-bira.zsh-theme
- [ ] Test prompt on all three machines
- [ ] Add color coding for different states

### UI/UX Tasks
- [ ] Add comprehensive help text
- [ ] Implement status display
- [ ] Add progress indicators
- [ ] Create confirmation prompts for destructive operations
- [ ] Add verbose mode option

### Testing Tasks
- [ ] Create test harness
- [ ] Write test cases for each command
- [ ] Test on work Mac (~/dev/configs)
- [ ] Test on personal Mac (~/dev/configs)
- [ ] Test on EC2 instance (~/configs)
- [ ] Test cross-machine syncing scenarios
- [ ] Document known issues and solutions

## Success Criteria

The sync system is successful when:
1. Configs stay synchronized across all three machines (work Mac, personal Mac, EC2) without manual intervention
2. Machine-specific settings remain isolated per environment
3. External files can be selectively synced
4. Conflicts are handled gracefully
5. Data loss is impossible (via backups)
6. The system requires zero maintenance once set up
7. Shell prompt shows real-time sync status
8. Different config paths (~/dev/configs vs ~/configs) are handled automatically
9. Background sync doesn't slow down shell startup