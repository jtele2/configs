# ======================================
# SMART GIT BRANCH TRUNCATION PATCH
# ======================================
# Intelligently truncates long git branch names (e.g., JIRA tickets)
# while preserving readability and customization options

# Configuration variables (can be set in .zshrc before this loads)
: ${ZSH_GIT_PROMPT_MAX_LENGTH:=20}           # Max branch name length
: ${ZSH_GIT_PROMPT_ELLIPSIS:="…"}           # Truncation indicator
: ${ZSH_GIT_PROMPT_SMART_TRUNCATE:=true}    # Smart truncation for JIRA-style branches
: ${ZSH_GIT_PROMPT_PRESERVE_PREFIX:=true}   # Keep ticket prefix in JIRA branches

# Cache variables for performance
typeset -g __ZSH_GIT_PROMPT_LAST_REF=""
typeset -g __ZSH_GIT_PROMPT_LAST_RESULT=""

# ======================================
# HELPER FUNCTION: Smart branch truncation
# ======================================
function __smart_truncate_branch() {
    local branch="$1"
    local max_length="${2:-$ZSH_GIT_PROMPT_MAX_LENGTH}"
    
    # If branch is short enough, return as-is
    if [[ ${#branch} -le $max_length ]]; then
        echo "$branch"
        return
    fi
    
    # Smart truncation for JIRA-style branches (e.g., PROJ-1234-long-description)
    if [[ "$ZSH_GIT_PROMPT_SMART_TRUNCATE" == "true" ]] && [[ "$branch" =~ ^([A-Z]+-[0-9]+)(-.*)?$ ]]; then
        local ticket="${match[1]}"
        local description="${match[2]}"
        
        if [[ "$ZSH_GIT_PROMPT_PRESERVE_PREFIX" == "true" ]] && [[ -n "$ticket" ]]; then
            # Calculate remaining space for description
            local remaining=$((max_length - ${#ticket} - ${#ZSH_GIT_PROMPT_ELLIPSIS}))
            
            if [[ $remaining -gt 0 ]] && [[ -n "$description" ]]; then
                # Show ticket + truncated description
                echo "${ticket}${description:0:$remaining}${ZSH_GIT_PROMPT_ELLIPSIS}"
            else
                # Just show ticket if no room for description
                echo "$ticket"
            fi
            return
        fi
    fi
    
    # Default truncation: keep first part and add ellipsis
    local truncated_length=$((max_length - ${#ZSH_GIT_PROMPT_ELLIPSIS}))
    echo "${branch:0:$truncated_length}${ZSH_GIT_PROMPT_ELLIPSIS}"
}

# ======================================
# OVERRIDE: Enhanced git_prompt_info with caching
# ======================================
function git_prompt_info() {
    # If we are on a folder not tracked by git, get out
    # Otherwise, check for hide-info at global and local repository level
    if ! __git_prompt_git rev-parse --git-dir &> /dev/null \
        || [[ "$(__git_prompt_git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
        return 0
    fi
    
    # Get the current ref (branch/tag/SHA)
    local ref
    ref=$(__git_prompt_git symbolic-ref --short HEAD 2> /dev/null) \
    || ref=$(__git_prompt_git describe --tags --exact-match HEAD 2> /dev/null) \
    || ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) \
    || return 0
    
    # Check cache to avoid redundant processing
    if [[ "$ref" == "$__ZSH_GIT_PROMPT_LAST_REF" ]] && [[ -n "$__ZSH_GIT_PROMPT_LAST_RESULT" ]]; then
        echo -n "$__ZSH_GIT_PROMPT_LAST_RESULT"
        echo "$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
        return
    fi
    
    # Process upstream info if requested
    local upstream=""
    if (( ${+ZSH_THEME_GIT_SHOW_UPSTREAM} )); then
        upstream=$(__git_prompt_git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null) \
        && upstream=" → ${upstream}"
    fi
    
    # Apply smart truncation
    local truncated_ref="$(__smart_truncate_branch "$ref")"
    
    # Cache the result (without dirty state since that changes frequently)
    __ZSH_GIT_PROMPT_LAST_REF="$ref"
    __ZSH_GIT_PROMPT_LAST_RESULT="${ZSH_THEME_GIT_PROMPT_PREFIX}${truncated_ref:gs/%/%%}${upstream:gs/%/%%}"
    
    # Output the complete prompt
    echo "${__ZSH_GIT_PROMPT_LAST_RESULT}$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

# ======================================
# OPTIONAL: Additional git prompt helpers
# ======================================

# Show full branch name on demand (useful for copying)
function git_full_branch() {
    __git_prompt_git symbolic-ref --short HEAD 2>/dev/null || \
    __git_prompt_git describe --tags --exact-match HEAD 2>/dev/null || \
    __git_prompt_git rev-parse --short HEAD 2>/dev/null
}

# Toggle between truncated and full branch display
function git_prompt_toggle_truncate() {
    if [[ "$ZSH_GIT_PROMPT_MAX_LENGTH" == "999" ]]; then
        ZSH_GIT_PROMPT_MAX_LENGTH=20
        echo "Git prompt truncation: ON (max: $ZSH_GIT_PROMPT_MAX_LENGTH chars)"
    else
        ZSH_GIT_PROMPT_MAX_LENGTH=999
        echo "Git prompt truncation: OFF"
    fi
}

# ======================================
# ALIASES FOR CONVENIENCE
# ======================================
alias gfb='git_full_branch'  # Show full branch name
alias gpt='git_prompt_toggle_truncate'  # Toggle truncation

# ======================================
# CONFIGURATION EXAMPLES
# ======================================
# Add these to your .zshrc BEFORE sourcing this file to customize:
#
# export ZSH_GIT_PROMPT_MAX_LENGTH=25        # Longer branch names
# export ZSH_GIT_PROMPT_ELLIPSIS="..."       # Different ellipsis
# export ZSH_GIT_PROMPT_SMART_TRUNCATE=false # Disable smart JIRA handling
# export ZSH_GIT_PROMPT_PRESERVE_PREFIX=false # Don't preserve JIRA ticket