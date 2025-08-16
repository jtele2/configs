# ===========================
# ZSH CONFIGURATION - OPTIMIZED
# ===========================

# Path to your oh-my-zsh installation
export ZSH=$HOME/.oh-my-zsh

# Path to custom zsh configuration (from configs repo)
# Detect correct path based on environment
if [[ -d "$HOME/dev/configs" ]]; then
    export ZSH_CUSTOM=$HOME/dev/configs/zsh_custom
else
    export ZSH_CUSTOM=$HOME/configs/zsh_custom
fi

# Set theme
ZSH_THEME="custom-bira"

# ===========================
# PERFORMANCE OPTIMIZATIONS
# ===========================

# Disable untracked files check for faster git prompt
DISABLE_UNTRACKED_FILES_DIRTY=true

# Skip permission checks on completion directories (faster startup)
ZSH_DISABLE_COMPFIX=true

# Disable magic functions if experiencing paste issues
# DISABLE_MAGIC_FUNCTIONS=true

# Set custom cache directory for better management
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ohmyzsh"

# Disable automatic title updates (minor performance gain)
DISABLE_AUTO_TITLE=true

# ===========================
# COMPLETION OPTIMIZATIONS
# ===========================

# Completion options for better performance
zstyle ':completion:*' accept-exact '*(N)'  # Accept exact matches immediately without expansion
zstyle ':completion:*' use-cache on  # Cache expensive completions for faster reuse
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR/completions  # Store cache in Oh My Zsh directory
zstyle ':completion:*' rehash true  # Auto-detect new commands without manual rehash

# Faster completion for kill command
zstyle ':completion:*:*:kill:*' menu yes select  # Show menu with arrow key navigation
zstyle ':completion:*:kill:*' force-list always  # Always show process list to verify target

# ===========================
# HISTORY CONFIGURATION
# ===========================

setopt sharehistory         # Share history between all zsh sessions
setopt extendedhistory      # Save timestamps and duration of commands
setopt histignorealldups    # Don't store duplicate commands
setopt histreduceblanks     # Remove unnecessary blanks from history
setopt histexpiredupsfirst  # Expire duplicates first when trimming history
setopt histfindnodups       # Don't display duplicates when searching
setopt nohistbeep           # Don't beep when accessing history
setopt nobeep               # Disable terminal beep

export HISTSIZE=10000       # History entries in memory
export SAVEHIST=100000      # History entries saved to disk
export HISTFILE=${HISTFILE:-$HOME/.zsh_history}

# ===========================
# OH MY ZSH CONFIGURATION
# ===========================

# Auto-update settings
zstyle ':omz:update' mode auto       # Auto-update without asking
zstyle ':omz:update' frequency 7     # Update every 7 days

# Core plugins (loaded always)
plugins=(
    # Essential plugins
    git                     # Git aliases and functions
    colored-man-pages       # Colorized man pages
    common-aliases          # Common command aliases
    fzf                     # Fuzzy finder integration
    direnv                  # Directory-based environments
    
    # Development essentials
    virtualenv              # Shows virtualenv in prompt
    autoswitch_virtualenv   # Auto-switch Python virtual environments
    docker                  # Docker aliases and completion
    docker-compose          # Docker Compose aliases and completion
    kubectl                 # Kubernetes management
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ===========================
# LAZY LOADING FOR HEAVY PLUGINS
# ===========================

# Function to lazy-load plugins on demand
lazy_load_plugin() {
    local plugin=$1
    local trigger_cmd=$2
    
    eval "
    $trigger_cmd() {
        unfunction $trigger_cmd
        source $ZSH/plugins/$plugin/$plugin.plugin.zsh 2>/dev/null || \
        source $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh 2>/dev/null
        $trigger_cmd \"\$@\"
    }
    "
}

# Lazy load AWS CLI (loads when 'aws' is first used)
lazy_load_plugin "aws" "aws"

# Lazy load Terraform (loads when 'terraform' or 'tf' is first used)
lazy_load_plugin "terraform" "terraform"
alias tf='terraform'

# Lazy load Helm
lazy_load_plugin "helm" "helm"

# Lazy load FluxCD
lazy_load_plugin "fluxcd" "flux"

# Lazy load GitHub CLI
lazy_load_plugin "github" "gh"

# Lazy load Istio
lazy_load_plugin "istioctl" "istioctl"

# Lazy load Kind
lazy_load_plugin "kind" "kind"

# ===========================
# CONDITIONAL PLUGIN LOADING
# ===========================

# Load kube-ps1 only if kubectl is available
if command -v kubectl &>/dev/null; then
    source $ZSH/plugins/kube-ps1/kube-ps1.plugin.zsh 2>/dev/null
    KUBE_PS1_ENABLED=off  # Start disabled, enable with 'kubeon'
fi

# Load NVM plugin only if NVM is installed
if [[ -d "$HOME/.nvm" ]]; then
    export NVM_LAZY_LOAD=true  # Enable lazy loading for NVM
    export NVM_COMPLETION=true
    plugins+=(nvm)
fi

# SSH agent (load only if not already running)
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    plugins+=(ssh-agent)
    zstyle :omz:plugins:ssh-agent identities id_rsa id_ed25519
    zstyle :omz:plugins:ssh-agent lifetime 4h
fi

# ===========================
# USER CONFIGURATION
# ===========================

# Editor preferences
export EDITOR='code'
export VISUAL='code'

# Aliases
alias l='ls -alh'
alias c='claude --dangerously-skip-permissions'

# Quick plugin management
alias plugin-list='echo ${plugins[@]}'
alias kubeon='KUBE_PS1_ENABLED=on'
alias kubeoff='KUBE_PS1_ENABLED=off'

# ===========================
# PLATFORM-SPECIFIC SETTINGS
# ===========================

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific
    # Homebrew on Apple Silicon (M1/M2)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    # Homebrew on Intel Macs
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # Lazy load syntax highlighting (if installed via Homebrew)
    if [[ -n "$HOMEBREW_PREFIX" ]] && [[ -f $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        # Defer loading until first prompt
        precmd_functions+=(load_syntax_highlighting)
        load_syntax_highlighting() {
            source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
            precmd_functions=(${precmd_functions:#load_syntax_highlighting})
        }
    fi
else
    # Linux specific
    # Linuxbrew if installed
    if [[ -d /home/linuxbrew/.linuxbrew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    # Syntax highlighting (common Linux paths)
    local syntax_highlight_paths=(
        "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    )
    
    for path in $syntax_highlight_paths; do
        if [[ -f "$path" ]]; then
            # Defer loading until first prompt
            precmd_functions+=(load_syntax_highlighting)
            load_syntax_highlighting() {
                source "$path"
                precmd_functions=(${precmd_functions:#load_syntax_highlighting})
            }
            break
        fi
    done
fi

# ===========================
# PATH OPTIMIZATION
# ===========================

# Remove duplicate PATH entries
typeset -U path PATH

# Add common development paths if they exist
local dev_paths=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "/usr/local/go/bin"
    "$HOME/go/bin"
)

for p in $dev_paths; do
    [[ -d "$p" ]] && path=("$p" $path)
done

# ===========================
# FINAL CONFIGURATIONS
# ===========================

# Load additional configurations if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load the vault token only on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    [[ -f "$HOME/.vault-token-prod" ]] && VAULT_URL_FOR_DYNACONF=$(cat $HOME/.vault-token-prod)
fi

# ===========================
# PERFORMANCE MONITORING (Optional)
# ===========================

# Uncomment to measure zsh startup time
# zmodload zsh/zprof  # At the top of .zshrc
# zprof  # At the bottom of .zshrc