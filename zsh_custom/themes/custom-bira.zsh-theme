# ======================================
# CUSTOM BIRA THEME - OPTIMIZED
# ======================================

# Git prompt configuration
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="$(git_prompt_short_sha)› %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗ %{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔ %{$fg[yellow]%}"

# Virtual environment configuration
ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$fg[green]%}‹"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX"
ZSH_THEME_VIRTUALENV_SUFFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"

# ======================================
# PROMPT COMPONENTS
# ======================================

# Current directory (truncated to last 2 segments for long paths)
local current_dir="%B%{$fg[blue]%}%(4~|…/%2~|%~) %{$reset_color%}"

# Git info (lazy loaded by git plugin)
local git_info='$(git_prompt_info)'

# Virtual environment (only shows when active)
local venv_info='$(virtualenv_prompt_info)'

# AWS profile (only show if not default and AWS_PROFILE is set)
local aws_info='${AWS_PROFILE:+%{$fg[magenta]%\}AWS:$AWS_PROFILE %{$reset_color%\}}'

# UTC time (cached per minute to reduce overhead)
local utc_time='%{$fg[white]%}%D{%H%M} %{$reset_color%}'

# Kubernetes context (check once at theme load, not every prompt)
if (( $+functions[kube_ps1] )); then
    local kube_info='$(kube_ps1) '
else
    local kube_info=''
fi

# Nix shell indicator (use parameter expansion instead of function)
local nix_indicator='${IN_NIX_SHELL:+🌿}'

# User symbol (# for root, $ for normal user)
local user_symbol='%(!.#.$)'

# Return code (only shows on error)
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# ======================================
# PROMPT ASSEMBLY
# ======================================

# Main prompt with two-line format
PROMPT="╭─${nix_indicator}${current_dir}${git_info}${venv_info}${aws_info}${kube_info}${utc_time}
╰─%B${user_symbol}%b "

# Right-side prompt shows return code
RPROMPT="%B${return_code}%b"

# ======================================
# PERFORMANCE OPTIMIZATIONS
# ======================================

# Enable git prompt async (if available in git plugin)
if (( $+functions[git_prompt_async] )); then
    ZSH_THEME_GIT_PROMPT_ASYNC=1
fi

# Reduce git prompt checks for large repos
ZSH_THEME_GIT_PROMPT_CACHE=1

# Skip expensive git operations in very large repos
ZSH_THEME_GIT_PROMPT_SKIP_LARGE_REPOS=1