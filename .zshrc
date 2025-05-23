# ##################################
# Options and settings for zsh

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# History Options
setopt sharehistory
setopt extendedhistory
setopt histignorealldups
setopt histreduceblanks
setopt nohistbeep
setopt nobeep
export HISTSIZE=10000
export SAVEHIST=10000

# Path to my oh-my-zsh custom plugins and themes.
for dir in "$HOME/configs" "$HOME/dev/configs"; do
    if [[ -d $dir ]]; then
        export ZSH_CUSTOM="$dir/zsh_custom"
        break
    fi
done

# General Options
DISABLE_UNTRACKED_FILES_DIRTY=true
ZSH_THEME="custom-bira"

# Homebrew - Platform specific configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    export PATH="/opt/homebrew/bin:$PATH"
    # zsh-syntax-highlighting for macOS
    # REF: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#how-to-install
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
    # Linux
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    # zsh-syntax-highlighting for Linux
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

zstyle ':omz:update' mode auto      # update automatically without asking

plugins=(    
    argocd
    aws
    colored-man-pages
    common-aliases
    docker
    docker-compose
    fluxcd # Causes the accepts at most 1 arg(s), received 2 issue if the wrong flux is installed
    fzf
    git
    git-auto-fetch
    git-prompt
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

# Keep this line here - its order matters
source $ZSH/oh-my-zsh.sh

# ===========================
# USER CONFIGURATION

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    # Use Visual Studio Code as the default editor for local sessions
    export CODE_EDITOR='code'
    export EDITOR='vim'
    export GIT_EDITOR='code --wait'
    export KUBE_EDITOR='nano'
    export LESS='--RAW-CONTROL-CHARS --quit-if-one-screen --no-init --ignore-case'
    export MANPAGER='less -i'
    export PAGER='less -i'
    export VISUAL='code'
fi
