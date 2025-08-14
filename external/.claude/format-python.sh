#!/bin/bash

# Cross-platform Python formatter for Claude Code hooks
# Works on both macOS and Linux

# Step 1: Extract the file path from the JSON input
# Claude Code passes tool information as JSON on stdin
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .file_path // empty' 2>/dev/null)

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to find and run formatter
find_and_run_formatter() {
    local file="$1"
    local formatter_cmd=""
    
    # Check for ruff in various locations
    if command_exists ruff; then
        formatter_cmd="ruff"
    elif [ -f "$HOME/dev/configs/csync/.venv/bin/ruff" ]; then
        formatter_cmd="$HOME/dev/configs/csync/.venv/bin/ruff"
    elif [ -f ".venv/bin/ruff" ]; then
        formatter_cmd=".venv/bin/ruff"
    elif [ -f "venv/bin/ruff" ]; then
        formatter_cmd="venv/bin/ruff"
    elif command_exists uv && [ -f "pyproject.toml" ]; then
        # Try using uv run if available
        cd "$(dirname "$file")" && uv run ruff --version >/dev/null 2>&1 && formatter_cmd="uv run ruff"
    fi
    
    # If we found ruff, use it
    if [ -n "$formatter_cmd" ]; then
        $formatter_cmd check --fix --unsafe-fixes "$file" 2>/dev/null
        $formatter_cmd format "$file" 2>/dev/null
        return 0
    fi
    
    # Try black as fallback
    if command_exists black; then
        black --quiet "$file" 2>/dev/null
        return 0
    fi
    
    # Try autopep8 as last resort
    if command_exists autopep8; then
        autopep8 --in-place "$file" 2>/dev/null
        return 0
    fi
    
    return 1
}

# Step 2: Check if we have a valid Python file
if [ -n "$file_path" ] && echo "$file_path" | grep -qE '\.(py|ipynb)$'; then
    find_and_run_formatter "$file_path"
fi

# Always exit successfully so we don't block the edit
exit 0