# ===========================
# ZSH CONFIGURATION
# ===========================

# Path to your oh-my-zsh installation
export ZSH=$HOME/.oh-my-zsh

# Path to custom zsh configuration (from configs repo)
# Adjust path based on user
if [[ "$USER" == "joe" ]] || [[ "$USER" == "work" ]]; then
    export ZSH_CUSTOM=$HOME/dev/configs/zsh_custom
else
    export ZSH_CUSTOM=$HOME/configs/zsh_custom
fi

# Set theme
ZSH_THEME="custom-bira"

# ===========================
# HISTORY CONFIGURATION
# ===========================

setopt sharehistory         # Share history between all zsh sessions
setopt extendedhistory      # Save timestamps and duration of commands
setopt histignorealldups    # Don't store duplicate commands
setopt histreduceblanks     # Remove unnecessary blanks from history
setopt nohistbeep          # Don't beep when accessing history
setopt nobeep              # Disable terminal beep

export HISTSIZE=10000       # History entries in memory
export SAVEHIST=100000      # History entries saved to disk

# ===========================
# OH MY ZSH CONFIGURATION
# ===========================

DISABLE_UNTRACKED_FILES_DIRTY=true  # Faster git prompt
zstyle ':omz:update' mode auto       # Auto-update without asking

# Plugins
plugins=(    
    autoswitch_virtualenv
    argocd
    aws
    colored-man-pages
    common-aliases
    direnv
    docker
    docker-compose
    fluxcd
    fzf
    git
    git-auto-fetch
    git-prompt
    github
    helm
    istioctl
    kind
    kube-ps1
    kubectl
    nvm
    ssh-agent
    terraform
    tmux
    virtualenv
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ===========================
# USER CONFIGURATION
# ===========================

# Editor preferences
export EDITOR='cursor'
export VISUAL='cursor'

# Aliases
alias code='cursor'
alias l='ls -alh'

# Platform-specific settings
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific
    # Homebrew on Apple Silicon (M1/M2)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    # Homebrew on Intel Macs
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # Syntax highlighting (if installed via Homebrew)
    if [[ -n "$HOMEBREW_PREFIX" ]] && [[ -f $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
else
    # Linux specific
    # Linuxbrew if installed
    if [[ -d /home/linuxbrew/.linuxbrew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    # Syntax highlighting (common Linux paths)
    if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    elif [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    elif [[ -n "$HOMEBREW_PREFIX" ]] && [[ -f $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        # Linuxbrew installed syntax highlighting
        source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
fi

# Remove duplicate PATH entries
typeset -U path PATH

# Load additional configurations if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load the vault token only on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    VAULT_URL_FOR_DYNACONF=$(cat $HOME/.vault-token-prod)
fi