# 🛠 Prompt pieces (simplified)
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
local user_symbol='%(!.#.$)'
local current_dir="%B%{$fg[blue]%}%~ %{$reset_color%}"
local aws_profile='%{$fg[yellow]%}aws_prof=${AWS_PROFILE:-default}%{$reset_color%}'
local utc_time='%{$fg[cyan]%}$(date -u +%H:%M:%S\ UTC)%{$reset_color%}'
local git_commit='%{$fg[magenta]%}$(git rev-parse --short HEAD 2>/dev/null)%{$reset_color%}'

local vcs_branch='$(git_prompt_info)$(hg_prompt_info)'
local venv_prompt='$(virtualenv_prompt_info)'
if [[ "${plugins[@]}" =~ 'kube-ps1' ]]; then
    local kube_prompt='$(kube_ps1)'
else
    local kube_prompt=''
fi

# 🧠 Configure the prompt in a function so VS Code can inject properly
function update_prompt() {
    PROMPT="╭─${current_dir}${vcs_branch}${venv_prompt}${kube_prompt} [${aws_profile}] ${utc_time} ${git_commit}
╰─%B${user_symbol}%b"
    RPROMPT="%B${return_code}%b"
}

# ✅ Register the prompt function as a precmd hook so VS Code shell integration survives
autoload -U add-zsh-hook
add-zsh-hook precmd update_prompt

# 💅 Theme bits for Git, virtualenv, etc.
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}●%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[yellow]%}"

ZSH_THEME_HG_PROMPT_PREFIX="$ZSH_THEME_GIT_PROMPT_PREFIX"
ZSH_THEME_HG_PROMPT_SUFFIX="$ZSH_THEME_GIT_PROMPT_SUFFIX"
ZSH_THEME_HG_PROMPT_DIRTY="$ZSH_THEME_GIT_PROMPT_DIRTY"
ZSH_THEME_HG_PROMPT_CLEAN="$ZSH_THEME_GIT_PROMPT_CLEAN"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$fg[green]%}‹"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX"
ZSH_THEME_VIRTUALENV_SUFFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
