# 🛠 Prompt pieces (simplified)

# Colors: cyan, white, yellow, magenta, black, blue, red, grey, green

# Display the virtual environment name if active
# Requires the 'virtualenv' plugin
# REF: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/virtualenv/virtualenv.plugin.zsh
ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$fg[green]%}‹"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX"
ZSH_THEME_VIRTUALENV_SUFFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
local venv_prompt='$(virtualenv_prompt_info)'

# Display the current directory in bold blue text
local current_dir="%B%{$fg[blue]%}%1~ %{$reset_color%}"

# Ensure git_prompt_info is properly defined and matches the working bira.zsh-theme
# Requires the 'git' plugin
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="$(git_prompt_short_sha)› %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔%{$fg[yellow]%}"
ZSH_THEME_GIT_SHOW_UPSTREAM='true'
DISABLE_UNTRACKED_FILES_DIRTY='true'
local git_prompt_info='$(git_prompt_info)'

# Display the current AWS profile in magenta, defaulting to 'default' if not set
local aws_profile='%{$fg[magenta]%}AWS:${AWS_PROFILE:-default} %{$reset_color%}'

# Display the current UTC time in white
local utc_time='%{$fg[white]%}$(TZ=UTC strftime %H%M) %{$reset_color%}'

# Check if the 'kube-ps1' plugin is active, and include Kubernetes context if so
if [[ "${plugins[@]}" =~ 'kube-ps1' ]]; then
    local kube_prompt='$(kube_ps1) '
else
    local kube_prompt=''
fi

# Define the user symbol, showing '#' for root and '$' for normal users
local user_symbol='%(!.#.$)'

# Define the return code display, showing a red arrow and the code if the last command failed
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# Add an 🌿 emoji to the prompt if in a nix-shell
function nix_indicator() {
    # Initialize an empty emoji for nix-shell
    local nix_shell_emoji=""

    # Add a leaf emoji if inside a nix-shell (pure or impure)
    if [[ "$IN_NIX_SHELL" == "1" || "$IN_NIX_SHELL" == "impure" ]]; then
        nix_shell_emoji="🌿"
    fi

    # Output the emoji
    echo "$nix_shell_emoji"
}

PROMPT="╭─$(nix_indicator)${current_dir}${git_prompt_info}${venv_prompt}${aws_profile}${kube_prompt}${utc_time}
╰─%B${user_symbol}%b"
# PROMPT="╭─$(nix_indicator)${current_dir}${git_prompt_info}%<<${aws_profile}${utc_time}${kube_prompt}${venv_prompt}

# Define the right-side prompt to show the return code
# RPROMPT="%B${return_code}%b"
# PROMPT='%10>…>thisisareallylongprompt'
# PROMPT='%10>…>'"${git_prompt_info}"'%<<someotherreallylongprompt'
RPROMPT="%B${return_code}%b"
