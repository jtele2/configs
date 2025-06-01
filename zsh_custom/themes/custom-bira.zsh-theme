# ──────────────────────────────────────────────────────────────
#  custom-bira.zsh-theme
#  A modern, informative, and minimal Zsh prompt built on the bira theme.
# ──────────────────────────────────────────────────────────────

# 🌈 Colors: cyan, white, yellow, magenta, black, blue, red, grey, green

# ── Color Definitions (Oh My Zsh best practice: use $fg[] and $reset_color)
#    These are used throughout the prompt for clarity and style.

# ── Virtualenv Section
#    Shows the Python virtual environment if active.
#    Requires the 'virtualenv' Oh My Zsh plugin.
# REF: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/virtualenv/virtualenv.plugin.zsh
ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$fg[green]%}‹"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX"
ZSH_THEME_VIRTUALENV_SUFFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
local venv_prompt='$(virtualenv_prompt_info)'

# ── Current Directory Section
#    Shows the current working directory in bold blue.
local current_dir="%B%{$fg[blue]%}%1~%b%{$reset_color%} "

# ── Git Section
#    Shows git branch/status if in a git repo.
#    Requires the 'git' Oh My Zsh plugin.
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="$(git_prompt_short_sha)› %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗ %{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔ %{$fg[yellow]%}"
local git_prompt_info='$(git_prompt_info)'

# ── AWS Profile Section
#    Shows the current AWS profile in magenta (defaults to 'default').
local aws_profile='%{$fg[magenta]%}AWS:${AWS_PROFILE:-default}%{$reset_color%} '

# ── UTC Time Section
#    Shows the current UTC time in white.
local utc_time='%{$fg[white]%}$(TZ=UTC strftime %H%M)%{$reset_color%} '

# ── Kubernetes Context Section (optional)
#    Shows the current Kubernetes context if the 'kube-ps1' plugin is active.
local kube_prompt=""
if (( ${+plugins} )) && [[ "${plugins[@]}" =~ 'kube-ps1' ]]; then
    kube_prompt='$(kube_ps1) '
fi

# ── User Symbol Section
#    Shows '#' for root, '$' for normal users.
local user_symbol='%(!.#.$)'

# ── Return Code Section
#    Shows a red arrow and code if the last command failed.
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# ── PROMPT and RPROMPT Definitions
#    Main prompt (left) and right prompt (return code).
PROMPT="╭─${current_dir}${git_prompt_info}${venv_prompt}${aws_profile}${kube_prompt}${utc_time}
╰─%B${user_symbol}%b "
# PROMPT="╭─$(nix_indicator)${current_dir}${git_prompt_info}%<<${aws_profile}${utc_time}${kube_prompt}${venv_prompt}

# Define the right-side prompt to show the return code
# RPROMPT="%B${return_code}%b"
# PROMPT='%10>…>thisisareallylongprompt'
# PROMPT='%10>…>'"${git_prompt_info}"'%<<someotherreallylongprompt'
RPROMPT="%B${return_code}%b"

# ── End of theme ───────────────────────────────────────────────
