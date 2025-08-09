# ############################################################
# My custom patch to oh-my-zsh's git plugin
# All this patch does is truncate the git ref to n characters

function _omz_git_prompt_info() {
  # If we are on a folder not tracked by git, get out.
  # Otherwise, check for hide-info at global and local repository level
  if ! __git_prompt_git rev-parse --git-dir &> /dev/null \
    || [[ "$(__git_prompt_git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
    return 0
  fi

  # Get either:
  # - the current branch name
  # - the tag name if we are on a tag
  # - the short SHA of the current commit
  local ref
  ref=$(__git_prompt_git symbolic-ref --short HEAD 2> /dev/null) \
  || ref=$(__git_prompt_git describe --tags --exact-match HEAD 2> /dev/null) \
  || ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) \
  || return 0

  # Use global ZSH_THEME_GIT_SHOW_UPSTREAM=1 for including upstream remote info
  local upstream
  if (( ${+ZSH_THEME_GIT_SHOW_UPSTREAM} )); then
    upstream=$(__git_prompt_git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null) \
    && upstream=" -> ${upstream}"
  fi

  # ###########################################################
  # Here is the patch. The original is this. Notice it just truncates the git ref to N chars
  # echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ref:gs/%/%%}${upstream:gs/%/%%}$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
  echo "${ZSH_THEME_GIT_PROMPT_PREFIX}"'%15>…>'"${ref:gs/%/%%}${upstream:gs/%/%%}"'%<<'"$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
  # ###########################################################
}
