#!/bin/bash

# This script is called by Claude Code after editing Python files
# It automatically formats Python code using ruff

# Optional: Enable debug logging
# DEBUG_LOG="/home/ubuntu/.claude/format-python.log"
# echo "$(date): Hook triggered" >> "$DEBUG_LOG"

# Step 1: Extract the file path from the JSON input
# Claude Code passes tool information as JSON on stdin
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .file_path // empty')

# Optional: Log the file path for debugging
# echo "$(date): Processing file: $file_path" >> "$DEBUG_LOG"

# Step 2: Check if we have a valid Python file
if [ -n "$file_path" ] && echo "$file_path" | grep -qE '\.(py|ipynb)$'; then
    # Step 3: Fix linting issues (imports, unused vars, etc.)
    # --fix: apply safe fixes
    # --unsafe-fixes: also apply fixes that might change behavior
    ruff check --fix --unsafe-fixes "$file_path"
    
    # Step 4: Format the code (spacing, line breaks, etc.)
    ruff format "$file_path"
fi

# Step 5: Always exit successfully so we don't block the edit
exit 0