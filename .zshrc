export ZSH="/home/ubuntu/.oh-my-zsh"
ZSH_THEME="fino"
zstyle ':omz:update' mode reminder  # just remind me to update when it's time
plugins=(
    git
    colored-man-pages
    docker
    docker-compose
    kubectl
    aws
    helm
    terraform
    fluxcd
    pyenv
)

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

# Source extra completions
fpath=(~/.zsh/completions $fpath)
source $ZSH/oh-my-zsh.sh
export EDITOR='vim'
export KIND_DIR=~/pathfinder-airgap/kind

# export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
# export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
# export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crtexport PYENV_ROOT="$HOME/.pyenv"