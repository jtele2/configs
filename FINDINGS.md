# Virtual Environment Deactivation Error Investigation

## Problem Statement

Error occurs when changing directories:

```
Deactivating: .venv
_default_venv:8: command not found: deactivate
```

## Root Cause Analysis

### 1. The Source of the Error

The error originates from the `autoswitch_virtualenv` plugin located at:
`/Users/joe/dev/configs/zsh_custom/plugins/autoswitch_virtualenv/autoswitch_virtualenv.plugin.zsh`

Specifically, the `_default_venv` function (lines 225-235) contains:

```zsh
function _default_venv()
{
    local venv_type="$(_get_venv_type "$OLDPWD")"
    if [[ -n "$AUTOSWITCH_DEFAULTENV" ]]; then
        _maybeworkon "$(_virtual_env_dir "$AUTOSWITCH_DEFAULTENV")" "$venv_type"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_name="$(_get_venv_name "$VIRTUAL_ENV" "$venv_type")"
        _autoswitch_message "Deactivating: ${AUTOSWITCH_BOLD}${AUTOSWITCH_PURPLE}%s${AUTOSWITCH_NORMAL}\n" "$venv_name"
        deactivate  # <-- LINE 233: This is where the error occurs
    fi
}
```

### 2. The Actual Problem

The issue is a **state mismatch** between the environment variable and shell functions:

- **Environment State**: `$VIRTUAL_ENV` is set to `/Users/joe/dev/impact/.venv`
- **Shell State**: The `deactivate` function is not defined in the current shell

This mismatch occurs because:

1. The `$VIRTUAL_ENV` environment variable persists across shell sessions or was set without properly sourcing the activate script
2. The `deactivate` function is only available when a virtual environment is properly activated (by sourcing its activate script)
3. The plugin assumes if `$VIRTUAL_ENV` is set, then `deactivate` must be available, which isn't always true

### 3. How This Happened

Several scenarios can cause this state mismatch:

1. **Shell Restart with Persistent Environment**: If the terminal was restarted but the `$VIRTUAL_ENV` variable persisted (e.g., through terminal app state restoration)

2. **Manual Environment Variable Setting**: If `$VIRTUAL_ENV` was set manually without activating the virtual environment

3. **Incomplete Activation**: If virtual environment activation failed partway through but still set the environment variable

4. **Cross-Shell Contamination**: If switching between different shell sessions or terminal tabs with different states

### 4. Plugin Behavior

The `autoswitch_virtualenv` plugin:

- Automatically activates/deactivates Python virtual environments when changing directories
- Uses the presence of `.venv`, `Pipfile`, or `poetry.lock` files to detect projects
- The `_default_venv` function is called when leaving a directory to potentially deactivate the current environment
- It incorrectly assumes `deactivate` is available whenever `$VIRTUAL_ENV` is set

## Solution

### Immediate Fix

Clear the stale environment variable:

```bash
unset VIRTUAL_ENV
```

### Long-term Fix

The plugin should be patched to check if `deactivate` is available before calling it:

**Location**: `/Users/joe/dev/configs/zsh_custom/plugins/autoswitch_virtualenv/autoswitch_virtualenv.plugin.zsh:233`

**Current code**:

```zsh
deactivate
```

**Fixed code**:

```zsh
if type deactivate > /dev/null 2>&1; then
    deactivate
else
    # Just unset the environment variable if deactivate isn't available
    unset VIRTUAL_ENV
    unset VIRTUAL_ENV_PROMPT
    # Reset PATH if needed
    if [[ -n "$_OLD_VIRTUAL_PATH" ]]; then
        PATH="$_OLD_VIRTUAL_PATH"
        unset _OLD_VIRTUAL_PATH
    fi
fi
```

## Additional Notes

1. **Recent Changes**: The zshrc was recently optimized (commit b22a83e) to improve performance, including changes to plugin loading. However, this optimization didn't directly cause the issue - it just exposed an existing bug in the autoswitch_virtualenv plugin.

2. **Plugin Configuration**: The plugin is loaded on line 88 of `/Users/joe/dev/configs/zshrc` as part of the core plugins.

3. **Affected Directories**: The error occurs in "all directories" because the plugin's `check_venv` function is triggered on every directory change (via the `chpwd` hook).

## Recommended Actions

1. **Immediate**: Run `unset VIRTUAL_ENV` to clear the stale environment variable
2. **Short-term**: Apply the patch to the autoswitch_virtualenv plugin to handle missing `deactivate` gracefully
3. **Long-term**: Consider submitting the fix upstream to the autoswitch_virtualenv plugin repository
