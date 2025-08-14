#!/bin/bash

# Config Sync System
# Syncs configuration files across work Mac, personal Mac, and EC2 instance

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Detect machine type and set configs directory
detect_environment() {
    if [[ -f /etc/ec2-metadata ]] || [[ -f /sys/hypervisor/uuid && $(head -c 3 /sys/hypervisor/uuid) == "ec2" ]]; then
        CONFIGS_DIR="$HOME/configs"
        MACHINE_TYPE="ec2"
    elif [[ "$(uname)" == "Darwin" ]]; then
        CONFIGS_DIR="$HOME/dev/configs"
        MACHINE_TYPE="mac"
    else
        # Fallback for other Linux systems
        CONFIGS_DIR="$HOME/configs"
        MACHINE_TYPE="linux"
    fi
    
    # Set other paths based on configs directory
    SYNC_DIR="$CONFIGS_DIR/.sync"
    BACKUP_DIR="$SYNC_DIR/backups"
    MACHINE_ID_FILE="$SYNC_DIR/machine-id"
    LAST_SYNC_FILE="$SYNC_DIR/last-sync"
    SYNC_STATUS_FILE="$SYNC_DIR/sync-status"
    MARKED_FILES="$SYNC_DIR/marked-files.txt"
    EXTERNAL_DIR="$CONFIGS_DIR/external"
    BRANCH="${SYNC_BRANCH:-main}"
}

# Initialize environment
detect_environment

# Ensure we're in the configs directory
cd "$CONFIGS_DIR" 2>/dev/null || {
    echo -e "${RED}❌ Config directory not found at $CONFIGS_DIR${NC}"
    echo -e "${YELLOW}Please clone the repository first:${NC}"
    echo -e "  git clone git@github.com:jtele2/configs.git $CONFIGS_DIR"
    exit 1
}

# Function to print colored output
log() {
    local message="$1"
    local color="${2:-$NC}"
    echo -e "${color}${message}${NC}"
}

# Function to update sync status for prompt
update_sync_status() {
    local status="$1"
    mkdir -p "$SYNC_DIR"
    echo "$status" > "$SYNC_STATUS_FILE"
}

# Function to get machine identifier
get_machine_id() {
    mkdir -p "$SYNC_DIR"
    if [[ ! -f "$MACHINE_ID_FILE" ]]; then
        # Generate machine ID based on hostname, username, and type
        echo "${USER}@$(hostname -s)-${MACHINE_TYPE}" > "$MACHINE_ID_FILE"
    fi
    cat "$MACHINE_ID_FILE"
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log "❌ Not a git repository. Initializing..." "$RED"
        git init
        git remote add origin git@github.com:jtele2/configs.git
        git fetch origin
        git checkout -b main origin/main
    fi
}

# Function to check network connectivity
check_network() {
    if ! git ls-remote --heads origin > /dev/null 2>&1; then
        log "❌ Cannot reach remote repository. Check network/SSH." "$RED"
        update_sync_status "%{$fg[red]%}✗%{$reset_color%}"
        return 1
    fi
    return 0
}

# Function to create backup
create_backup() {
    local backup_name="backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    mkdir -p "$BACKUP_DIR"
    
    log "📦 Creating backup: $backup_name" "$BLUE"
    
    # Create backup including marked external files
    tar czf "$BACKUP_DIR/$backup_name" \
        --exclude=.git \
        --exclude=.sync \
        --exclude='*.local' \
        --exclude=node_modules \
        --exclude=.DS_Store \
        -C "$CONFIGS_DIR" . 2>/dev/null
    
    # Keep only last 10 backups
    ls -t "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
    
    return 0
}

# Function to restore from backup
restore_backup() {
    local backup_file="$1"
    
    if [[ -z "$backup_file" ]]; then
        # Show available backups
        log "Available backups:" "$CYAN"
        ls -la "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | tail -10
        
        log "\nTo restore, run: $0 --restore BACKUP_FILE" "$YELLOW"
        return 1
    fi
    
    if [[ ! -f "$BACKUP_DIR/$backup_file" ]]; then
        # Check if it's just the filename without path
        if [[ -f "$BACKUP_DIR/backup-$backup_file.tar.gz" ]]; then
            backup_file="backup-$backup_file.tar.gz"
        else
            log "❌ Backup file not found: $backup_file" "$RED"
            return 1
        fi
    fi
    
    log "🔄 Restoring from $backup_file..." "$YELLOW"
    
    # Create a restore point first
    create_backup
    
    # Extract backup
    tar xzf "$BACKUP_DIR/$backup_file" -C "$CONFIGS_DIR"
    
    log "✅ Restored from backup successfully" "$GREEN"
    return 0
}

# Function to create config symlinks
create_symlinks() {
    local force="${1:-false}"
    
    # Define symlinks to create (using arrays for compatibility)
    local sources=("$CONFIGS_DIR/zshrc" "$CONFIGS_DIR/direnvrc")
    local targets=("$HOME/.zshrc" "$HOME/.direnvrc")
    
    for i in "${!sources[@]}"; do
        local source="${sources[$i]}"
        local target="${targets[$i]}"
        
        # Skip if source doesn't exist
        [[ ! -f "$source" ]] && continue
        
        # Check if target already points to source
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            continue
        fi
        
        # Handle existing files
        if [[ -e "$target" ]] || [[ -L "$target" ]]; then
            if [[ "$force" == "true" ]]; then
                log "  Replacing: $target" "$YELLOW"
                rm -f "$target"
            else
                log "  Skipping: $target (already exists)" "$YELLOW"
                continue
            fi
        fi
        
        # Create symlink
        ln -sf "$source" "$target"
        log "  ✓ Linked: $target → $source" "$GREEN"
    done
}

# Function to setup sync environment
setup_sync() {
    log "🔧 Setting up sync environment..." "$BLUE"
    
    # Create directory structure
    mkdir -p "$SYNC_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$EXTERNAL_DIR"
    
    # Get machine ID
    local machine_id=$(get_machine_id)
    log "📍 Machine ID: $machine_id" "$GREEN"
    
    # Create marked files list if it doesn't exist
    touch "$MARKED_FILES"
    
    # Create config symlinks
    log "🔗 Creating config symlinks..." "$BLUE"
    create_symlinks true
    
    # Create zshrc.local if it doesn't exist
    if [[ ! -f "$CONFIGS_DIR/zshrc.local" ]]; then
        cat > "$CONFIGS_DIR/zshrc.local" <<EOF
# Machine-specific configuration for $machine_id
# This file is not synced and can contain local customizations

# Example: Work-specific aliases
# alias work-vpn='sudo openconnect vpn.company.com'

# Example: Personal-specific paths
# export PERSONAL_PROJECTS="\$HOME/personal"

# Machine type: $MACHINE_TYPE
# Config path: $CONFIGS_DIR
EOF
        log "✅ Created zshrc.local for machine-specific settings" "$GREEN"
    fi
    
    # Update .gitignore
    if [[ ! -f "$CONFIGS_DIR/.gitignore" ]] || ! grep -q "^.sync/" "$CONFIGS_DIR/.gitignore" 2>/dev/null; then
        cat >> "$CONFIGS_DIR/.gitignore" <<EOF

# Sync system files
.sync/
*.local
.DS_Store
node_modules/

# Backup files
*.backup
*.bak
*~
EOF
        log "✅ Updated .gitignore" "$GREEN"
    fi
    
    # Add source line to zshrc if not present
    if ! grep -q "source.*zshrc.local" "$CONFIGS_DIR/zshrc" 2>/dev/null; then
        echo -e "\n# Source machine-specific configuration\n[ -f ~/.zshrc.local ] && source ~/.zshrc.local" >> "$CONFIGS_DIR/zshrc"
        log "✅ Updated zshrc to source local config" "$GREEN"
    fi
    
    # Initialize git if needed
    check_git_repo
    
    # Initial status
    update_sync_status ""
    
    log "✅ Setup complete!" "$GREEN"
    log "\nNext steps:" "$CYAN"
    log "  1. Review and edit $CONFIGS_DIR/zshrc.local for machine-specific settings" "$NC"
    log "  2. Run '$0' to sync with remote" "$NC"
    log "  3. Mark external files with '$0 --mark <file>'" "$NC"
}

# Function to mark a file for syncing
mark_file() {
    local file_path="$1"
    
    # Resolve to absolute path
    file_path=$(realpath "$file_path" 2>/dev/null)
    
    if [[ ! -e "$file_path" ]]; then
        log "❌ File not found: $file_path" "$RED"
        return 1
    fi
    
    # Check if already marked
    if grep -q "^$file_path$" "$MARKED_FILES" 2>/dev/null; then
        log "ℹ️  File already marked: $file_path" "$YELLOW"
        return 0
    fi
    
    # Calculate relative path for external directory
    local rel_path="${file_path#$HOME/}"
    local external_path="$EXTERNAL_DIR/$rel_path"
    local external_parent=$(dirname "$external_path")
    
    # Create directory structure in external
    mkdir -p "$external_parent"
    
    # Copy file to external directory
    if [[ -d "$file_path" ]]; then
        cp -r "$file_path" "$external_path"
    else
        cp "$file_path" "$external_path"
    fi
    
    # Create symlink
    rm -rf "$file_path"
    ln -s "$external_path" "$file_path"
    
    # Add to marked files list
    echo "$file_path" >> "$MARKED_FILES"
    
    # Add to git
    cd "$CONFIGS_DIR"
    git add "$external_path"
    git commit -m "Mark file for sync: $rel_path"
    
    log "✅ Marked for sync: $file_path" "$GREEN"
    log "   Linked to: $external_path" "$CYAN"
    
    return 0
}

# Function to unmark a file
unmark_file() {
    local file_path="$1"
    
    # Resolve to absolute path
    file_path=$(realpath "$file_path" 2>/dev/null || echo "$file_path")
    
    # Check if marked
    if ! grep -q "^$file_path$" "$MARKED_FILES" 2>/dev/null; then
        log "ℹ️  File not marked: $file_path" "$YELLOW"
        return 0
    fi
    
    # Calculate paths
    local rel_path="${file_path#$HOME/}"
    local external_path="$EXTERNAL_DIR/$rel_path"
    
    # Replace symlink with actual file
    if [[ -L "$file_path" ]] && [[ -e "$external_path" ]]; then
        rm "$file_path"
        if [[ -d "$external_path" ]]; then
            cp -r "$external_path" "$file_path"
        else
            cp "$external_path" "$file_path"
        fi
    fi
    
    # Remove from marked files list
    grep -v "^$file_path$" "$MARKED_FILES" > "$MARKED_FILES.tmp"
    mv "$MARKED_FILES.tmp" "$MARKED_FILES"
    
    # Remove from git
    cd "$CONFIGS_DIR"
    git rm -r "$external_path" 2>/dev/null
    git commit -m "Unmark file from sync: $rel_path"
    
    log "✅ Unmarked from sync: $file_path" "$GREEN"
    
    return 0
}

# Function to list marked files
list_marked_files() {
    if [[ ! -s "$MARKED_FILES" ]]; then
        log "No files marked for sync" "$YELLOW"
        return 0
    fi
    
    log "Files marked for sync:" "$CYAN"
    while IFS= read -r file; do
        if [[ -L "$file" ]]; then
            echo "  ✓ $file"
        else
            echo "  ⚠ $file (not linked)"
        fi
    done < "$MARKED_FILES"
}

# Function to sync marked files
sync_marked_files() {
    [[ ! -s "$MARKED_FILES" ]] && return 0
    
    while IFS= read -r file_path; do
        local rel_path="${file_path#$HOME/}"
        local external_path="$EXTERNAL_DIR/$rel_path"
        
        # Ensure symlink exists
        if [[ ! -L "$file_path" ]] && [[ -e "$external_path" ]]; then
            if [[ -e "$file_path" ]]; then
                rm -rf "$file_path"
            fi
            ln -s "$external_path" "$file_path"
        fi
    done < "$MARKED_FILES"
}

# Function to check sync status
check_sync_status() {
    cd "$CONFIGS_DIR" || return 1
    
    # Fetch latest
    git fetch origin "$BRANCH" &>/dev/null
    
    local LOCAL=$(git rev-parse "$BRANCH" 2>/dev/null)
    local REMOTE=$(git rev-parse "origin/$BRANCH" 2>/dev/null)
    local BASE=$(git merge-base "$BRANCH" "origin/$BRANCH" 2>/dev/null)
    
    if [[ -z "$LOCAL" ]]; then
        echo "no-repo"
    elif [[ "$LOCAL" == "$REMOTE" ]]; then
        echo "synced"
    elif [[ "$LOCAL" == "$BASE" ]]; then
        echo "behind"
    elif [[ "$REMOTE" == "$BASE" ]]; then
        echo "ahead"
    else
        echo "diverged"
    fi
}

# Function to setup addons (plugins, completions, etc.)
setup_addons() {
    log "🎨 Setting up addons and plugins..." "$CYAN"
    
    # Run setup_plugins.sh if it exists
    if [[ -f "$CONFIGS_DIR/setup_plugins.sh" ]]; then
        log "📦 Installing Oh My Zsh custom plugins..." "$BLUE"
        bash "$CONFIGS_DIR/setup_plugins.sh"
    else
        log "⚠️  setup_plugins.sh not found" "$YELLOW"
    fi
    
    # Install Oh My Zsh if not present
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "💎 Oh My Zsh not found. Would you like to install it? (y/n)" "$YELLOW"
        read -r response
        if [[ "$response" == "y" ]]; then
            log "Installing Oh My Zsh..." "$BLUE"
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            log "✅ Oh My Zsh installed" "$GREEN"
        fi
    fi
    
    # Additional addon setups can be added here
    log "✅ Addon setup complete!" "$GREEN"
    log "💡 Restart your shell or run 'source ~/.zshrc' to load changes" "$YELLOW"
}

# Function to perform sync
sync_configs() {
    local force_push=false
    local force_pull=false
    local dry_run=false
    local background=false
    
    # Parse sync-specific flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force-push)
                force_push=true
                shift
                ;;
            --force-pull)
                force_pull=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --background)
                background=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Check network
    if ! check_network; then
        [[ "$background" == "false" ]] && log "❌ Network check failed" "$RED"
        return 1
    fi
    
    # Update status - syncing
    update_sync_status "%{$fg[blue]%}⚡%{$reset_color%}"
    
    # Get machine ID
    local machine_id=$(get_machine_id)
    [[ "$background" == "false" ]] && log "🔄 Starting sync from: $machine_id" "$BLUE"
    
    # Create backup (unless in background mode)
    if [[ "$dry_run" == "false" ]] && [[ "$background" == "false" ]]; then
        create_backup
    fi
    
    cd "$CONFIGS_DIR"
    
    # Fetch latest changes
    [[ "$background" == "false" ]] && log "📥 Fetching remote changes..." "$YELLOW"
    git fetch origin "$BRANCH" &>/dev/null
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        [[ "$background" == "false" ]] && log "📝 Uncommitted local changes detected" "$YELLOW"
        
        if [[ "$dry_run" == "true" ]]; then
            log "DRY RUN: Would stash local changes" "$BLUE"
            git status --short
        else
            git stash push -m "Auto-stash by sync from $machine_id at $(date '+%Y-%m-%d %H:%M:%S')" &>/dev/null
            [[ "$background" == "false" ]] && log "✅ Local changes stashed" "$GREEN"
        fi
    fi
    
    # Handle force operations
    if [[ "$force_push" == "true" ]]; then
        log "⬆️  Force pushing local changes..." "$YELLOW"
        if [[ "$dry_run" == "true" ]]; then
            log "DRY RUN: Would force push to origin/$BRANCH" "$BLUE"
        else
            git push --force origin "$BRANCH"
            log "✅ Force pushed to remote" "$GREEN"
            update_sync_status "%{$fg[green]%}✓%{$reset_color%}"
        fi
        return 0
    elif [[ "$force_pull" == "true" ]]; then
        log "⬇️  Force pulling remote changes..." "$YELLOW"
        if [[ "$dry_run" == "true" ]]; then
            log "DRY RUN: Would reset to origin/$BRANCH" "$BLUE"
        else
            git reset --hard "origin/$BRANCH"
            log "✅ Reset to remote state" "$GREEN"
            sync_marked_files
            update_sync_status "%{$fg[green]%}✓%{$reset_color%}"
        fi
        return 0
    fi
    
    # Normal sync operation
    LOCAL=$(git rev-parse "$BRANCH" 2>/dev/null)
    REMOTE=$(git rev-parse "origin/$BRANCH" 2>/dev/null)
    
    if [[ "$LOCAL" != "$REMOTE" ]]; then
        [[ "$background" == "false" ]] && log "📥 Pulling remote changes..." "$YELLOW"
        
        if [[ "$dry_run" == "true" ]]; then
            log "DRY RUN: Would pull and rebase from origin/$BRANCH" "$BLUE"
            git log --oneline "$LOCAL..origin/$BRANCH" 2>/dev/null
        else
            # Try rebase first
            if ! git pull --rebase origin "$BRANCH" &>/dev/null; then
                [[ "$background" == "false" ]] && log "⚠️  Rebase failed, attempting merge..." "$YELLOW"
                git rebase --abort &>/dev/null
                
                # Try merge
                if ! git pull --no-rebase origin "$BRANCH" &>/dev/null; then
                    log "❌ Merge failed. Manual intervention required." "$RED"
                    log "💡 Try: $0 --force-pull (loses local) or --force-push (loses remote)" "$YELLOW"
                    update_sync_status "%{$fg[red]%}✗%{$reset_color%}"
                    return 1
                fi
            fi
            [[ "$background" == "false" ]] && log "✅ Pulled remote changes" "$GREEN"
        fi
    else
        [[ "$background" == "false" ]] && log "✅ Already up to date with remote" "$GREEN"
    fi
    
    # Apply stashed changes if any
    if git stash list | grep -q "Auto-stash by sync" 2>/dev/null; then
        [[ "$background" == "false" ]] && log "📝 Applying stashed changes..." "$YELLOW"
        
        if [[ "$dry_run" == "true" ]]; then
            log "DRY RUN: Would apply stashed changes" "$BLUE"
        else
            if ! git stash pop &>/dev/null; then
                log "⚠️  Conflicts while applying stash" "$YELLOW"
                log "💡 Resolve conflicts manually, then run: git stash drop" "$YELLOW"
                update_sync_status "%{$fg[red]%}✗%{$reset_color%}"
                return 1
            fi
        fi
    fi
    
    # Sync marked files
    sync_marked_files
    
    # Commit any uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        [[ "$background" == "false" ]] && log "💾 Committing local changes..." "$YELLOW"
        
        if [[ "$dry_run" == "true" ]]; then
            log "DRY RUN: Would commit changes" "$BLUE"
            git status --short
        else
            git add -A
            git commit -m "Sync from $machine_id at $(date '+%Y-%m-%d %H:%M:%S')" &>/dev/null
            [[ "$background" == "false" ]] && log "✅ Changes committed" "$GREEN"
        fi
    fi
    
    # Push to remote
    LOCAL=$(git rev-parse "$BRANCH" 2>/dev/null)
    REMOTE=$(git rev-parse "origin/$BRANCH" 2>/dev/null)
    
    if [[ "$LOCAL" != "$REMOTE" ]]; then
        [[ "$background" == "false" ]] && log "⬆️  Pushing to remote..." "$YELLOW"
        
        if [[ "$dry_run" == "true" ]]; then
            log "DRY RUN: Would push to origin/$BRANCH" "$BLUE"
            git log --oneline "origin/$BRANCH..$LOCAL" 2>/dev/null
        else
            if git push origin "$BRANCH" &>/dev/null; then
                [[ "$background" == "false" ]] && log "✅ Pushed to remote" "$GREEN"
                update_sync_status "%{$fg[green]%}✓%{$reset_color%}"
            else
                log "❌ Push failed. Pull might be required first." "$RED"
                update_sync_status "%{$fg[yellow]%}↑%{$reset_color%}"
                return 1
            fi
        fi
    else
        update_sync_status "%{$fg[green]%}✓%{$reset_color%}"
    fi
    
    # Update last sync time
    if [[ "$dry_run" == "false" ]]; then
        date '+%Y-%m-%d %H:%M:%S' > "$LAST_SYNC_FILE"
        
        # Create/update symlinks after successful sync (not in background mode)
        if [[ "$background" == "false" ]]; then
            log "🔗 Updating config symlinks..." "$BLUE"
            create_symlinks false
            log "✅ Sync completed successfully!" "$GREEN"
        fi
    else
        log "✅ Dry run completed" "$BLUE"
    fi
    
    return 0
}

# Function to show status
show_status() {
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "$CYAN"
    log "  Config Sync Status" "$CYAN"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "$CYAN"
    
    log "\n📍 Machine Info:" "$YELLOW"
    echo "  Type: $MACHINE_TYPE"
    echo "  ID: $(get_machine_id)"
    echo "  Config Path: $CONFIGS_DIR"
    
    log "\n📊 Sync Status:" "$YELLOW"
    local status=$(check_sync_status)
    case $status in
        synced)
            echo -e "  ${GREEN}✓ Synced${NC} - Everything up to date"
            ;;
        ahead)
            echo -e "  ${YELLOW}↑ Ahead${NC} - Local changes need pushing"
            ;;
        behind)
            echo -e "  ${CYAN}↓ Behind${NC} - Remote changes available"
            ;;
        diverged)
            echo -e "  ${RED}⟷ Diverged${NC} - Both local and remote changes"
            ;;
        no-repo)
            echo -e "  ${RED}✗ No repository${NC} - Run --setup first"
            ;;
    esac
    
    if [[ -f "$LAST_SYNC_FILE" ]]; then
        echo "  Last sync: $(cat "$LAST_SYNC_FILE")"
    else
        echo "  Last sync: Never"
    fi
    
    log "\n📁 Marked Files:" "$YELLOW"
    local marked_count=$(wc -l < "$MARKED_FILES" 2>/dev/null || echo "0")
    echo "  Count: $marked_count files"
    if [[ $marked_count -gt 0 ]] && [[ $marked_count -le 5 ]]; then
        while IFS= read -r file; do
            echo "    - $file"
        done < "$MARKED_FILES"
    elif [[ $marked_count -gt 5 ]]; then
        head -3 "$MARKED_FILES" | while IFS= read -r file; do
            echo "    - $file"
        done
        echo "    ... and $((marked_count - 3)) more"
    fi
    
    log "\n💾 Backups:" "$YELLOW"
    local backup_count=$(ls "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | wc -l)
    echo "  Count: $backup_count backups"
    if [[ $backup_count -gt 0 ]]; then
        echo "  Latest: $(ls -t "$BACKUP_DIR"/backup-*.tar.gz | head -1 | xargs basename)"
    fi
    
    log "\n🔧 Git Status:" "$YELLOW"
    cd "$CONFIGS_DIR"
    local changes=$(git status --porcelain | wc -l)
    echo "  Branch: $BRANCH"
    echo "  Uncommitted changes: $changes"
    
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "$CYAN"
}

# Function to show help
show_help() {
    cat <<EOF
$(log "Config Sync System" "$CYAN")
$(log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "$CYAN")

Sync configuration files across work Mac, personal Mac, and EC2 instance.

$(log "USAGE:" "$YELLOW")
  $0 [OPTIONS]

$(log "BASIC COMMANDS:" "$YELLOW")
  (no args)           Perform normal sync
  --setup             Initial setup on new machine
  --status            Show sync status and info
  --help              Show this help message

$(log "FILE MARKING:" "$YELLOW")
  --mark PATH         Mark a file/directory for syncing
  --unmark PATH       Stop syncing a file/directory
  --list-marked       List all marked files

$(log "SYNC CONTROL:" "$YELLOW")
  --force-push        Force push local changes (overwrites remote)
  --force-pull        Force pull remote changes (overwrites local)
  --dry-run           Preview what would happen without changes
  --background        Run sync in background (quiet mode)

$(log "BACKUP & RECOVERY:" "$YELLOW")
  --backup            Create backup only, no sync
  --restore [FILE]    Restore from backup (interactive if no file)
  --list-backups      List available backups

$(log "ADDONS & SETUP:" "$YELLOW")
  --setup-addons      Install plugins, completions, and other addons
  --create-symlinks   Manually create config symlinks

$(log "EXAMPLES:" "$YELLOW")
  $0                          # Normal sync
  $0 --setup                  # First-time setup
  $0 --mark ~/.config/app     # Mark external file for sync
  $0 --dry-run                # Preview sync changes
  $0 --force-pull             # Overwrite local with remote
  $0 --setup-addons           # Install plugins and addons

$(log "MACHINE PATHS:" "$YELLOW")
  Mac:    ~/dev/configs
  EC2:    ~/configs
  
Current: $CONFIGS_DIR (detected as $MACHINE_TYPE)

EOF
}

# Main script logic
main() {
    # Handle no arguments - default sync
    if [[ $# -eq 0 ]]; then
        sync_configs
        exit $?
    fi
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --setup)
                setup_sync
                exit $?
                ;;
            --status)
                show_status
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --mark)
                mark_file "$2"
                exit $?
                ;;
            --unmark)
                unmark_file "$2"
                exit $?
                ;;
            --list-marked)
                list_marked_files
                exit 0
                ;;
            --backup)
                create_backup
                exit $?
                ;;
            --restore)
                restore_backup "$2"
                exit $?
                ;;
            --list-backups)
                log "Available backups:" "$CYAN"
                ls -la "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null || log "No backups found" "$YELLOW"
                exit 0
                ;;
            --setup-addons)
                setup_addons
                exit $?
                ;;
            --create-symlinks)
                log "🔗 Creating config symlinks..." "$BLUE"
                create_symlinks true
                exit $?
                ;;
            --force-push|--force-pull|--dry-run|--background)
                sync_configs "$@"
                exit $?
                ;;
            *)
                log "Unknown option: $1" "$RED"
                log "Run '$0 --help' for usage" "$YELLOW"
                exit 1
                ;;
        esac
        shift
    done
}

# Run main function
main "$@"