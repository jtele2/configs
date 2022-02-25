# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/ubuntu/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    colored-man-pages
    docker
    docker-compose
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias rm='echo "This is not the command you are looking for."; false'

# Git completions downloaded from:
# https://github.com/git/git/blob/master/contrib/completion/git-completion.zsh
fpath=(~/.zsh $fpath)

# Zscaler certificate stores
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Port forwarding for argos demo. 
alias demo_argos_http="ssh -NT i-0abc89187f1e2e2aa.us-east-2 -L 8080:internal-eks-rancher-private-clb-227542248.us-east-2.elb.amazonaws.com:80 && ssh -NT i-0abc89187f1e2e2aa.us-east-2 -L 9090:internal-eks-rancher-private-clb-227542248.us-east-2.elb.amazonaws.com:9090 && ssh -NT i-0abc89187f1e2e2aa.us-east-2 -L 5000:internal-eks-rancher-private-clb-227542248.us-east-2.elb.amazonaws.com:5000"
alias demo_argos_https="ssh -NTv i-0abc89187f1e2e2aa.us-east-2 -L 8443:internal-eks-rancher-private-clb-227542248.us-east-2.elb.amazonaws.com:443"
alias demo_argos_dags="kubectl port-forward svc/argos-airflow-web 8181:8080"
alias demo_argos_exit="ssh -TO exit i-0abc89187f1e2e2aa.us-east-2"

# AWS command line completion
export PATH=/usr/local/bin/aws_completer:$PATH
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/local/bin/aws_completer' aws

# AWS SSM aliases
alias ssm_my_sessions='aws ssm describe-sessions --state "Active" --filters "key=Owner,value=arn:aws:iam::751486495581:user/josiah.caprino"'

# EC2 aliases
alias ec2_start_cpu='aws ec2 start-instances --instance-ids i-0abc89187f1e2e2aa'
alias ec2_describe_cpu='aws ec2 describe-instance-status --instance-ids i-0abc89187f1e2e2aa'
alias ec2_stop_cpu='aws ec2 stop-instances --instance-ids i-0abc89187f1e2e2aa'
alias ec2_reboot_cpu='aws ec2 reboot-instances --instance-ids i-0abc89187f1e2e2aa'
alias ec2_start_gpu='aws ec2 start-instances --instance-ids i-0808afe182a3f57a0' 
alias ec2_describe_gpu='aws ec2 describe-instance-status --instance-ids i-0808afe182a3f57a0'
alias ec2_stop_gpu='aws ec2 stop-instances --instance-ids i-0808afe182a3f57a0'
alias ec2_reboot_gpu='aws ec2 reboot-instances --instance-ids i-0808afe182a3f57a0'

# Docker aliases
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Size}}\t{{.Ports}}"' 
alias port_forward_vscode='ssh -v -NL localhost:23750:/var/run/docker.sock i-0808afe182a3f57a0.us-east-2'

# Kubernetes 
[[ /usr/bin/kubectl ]] && source <(kubectl completion zsh)
alias kgp='kubectl get pods'
alias ktop='kubectl top pod'
alias k='kubectl'
complete -F __start_kubectl k

# alias kubectl="minikube kubectl --"

# Airflow
alias airflow_docker='./airflow.sh'
autoload bashcompinit && bashcompinit
eval "$(register-python-argcomplete airflow)"

# Aws IAM Authenticator
export PATH=$PATH:$HOME/bin

# WSL Specific
cd

# Remove user:host from prompt segment
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
#    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/ubuntu/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/ubuntu/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/ubuntu/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/ubuntu/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

