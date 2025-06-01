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

local exit_code="%(?,,C:%{$fg[red]%}%?%{$reset_color%})"

PROMPT="%{$terminfo[bold]$fg[blue]%}%{$reset_color%}\
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%}\
${git_info} \
${kube_info}\
 \
[\$(date -u +'%H:%M:%S')] $exit_code
%{$terminfo[bold]$fg[red]%}$ %{$reset_color%}"
