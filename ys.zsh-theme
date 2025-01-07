# Clean, simple, compatible and meaningful.
# Tested on Linux, Unix and Windows under ANSI colors.
# It is recommended to use with a dark background.
# Colors: black, red, green, yellow, *blue, magenta, cyan, and white.
#
# Mar 2013 Yad Smood

# VCS
YS_VCS_PROMPT_PREFIX1=" %{$reset_color%}on%{$fg[blue]%} "
YS_VCS_PROMPT_PREFIX2=":%{$fg[cyan]%}"
YS_VCS_PROMPT_SUFFIX="%{$reset_color%}"
YS_VCS_PROMPT_DIRTY=" %{$fg[red]%}x"
YS_VCS_PROMPT_CLEAN=" %{$fg[green]%}o"

# Git info
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}git${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"

# KUBE-PS1 settings
function get_cluster_short() {
  local cluster_short=$(echo "$1" | awk -F'[@.]' '{print $3 ":" $NF}')
  echo "$cluster_short"
}
if [[ "${plugins[@]}" =~ 'kube-ps1' ]]; then
  KUBE_PS1_CTX_COLOR='blue'
  KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
  local kube_info='$(kube_ps1)'
else
  local kube_info=''
fi

# Virtualenv with venv support
local venv_info='$(virtenv_prompt)'
YS_THEME_VIRTUALENV_PROMPT_PREFIX=" %{$fg[green]%}"
YS_THEME_VIRTUALENV_PROMPT_SUFFIX=" %{$reset_color%}"

virtenv_prompt() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "${YS_THEME_VIRTUALENV_PROMPT_PREFIX}$(basename $VIRTUAL_ENV)${YS_THEME_VIRTUALENV_PROMPT_SUFFIX}"
    fi
}

local exit_code="%(?,,C:%{$fg[red]%}%?%{$reset_color%})"

# Prompt format:
#
# PRIVILEGES USER @ MACHINE in DIRECTORY on git:BRANCH STATE [TIME] C:LAST_EXIT_CODE
# $ COMMAND
#
# For example:
#
# % ys @ ys-mbp in ~/.oh-my-zsh on git:master x [21:47:42] C:0
# $
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%}\
${git_info} \
${venv_info}\
${kube_info}\
 \
[\$(date -u +'%H:%M:%S')] $exit_code
%{$terminfo[bold]$fg[red]%}$ %{$reset_color%}"
