#!/bin/bash
# Source this file in your .zshrc or .bashrc to use csync command

# Detect the configs directory
if [[ -d "$HOME/dev/configs" ]]; then
    CONFIGS_DIR="$HOME/dev/configs"
elif [[ -d "$HOME/configs" ]]; then
    CONFIGS_DIR="$HOME/configs"
else
    echo "Warning: configs directory not found"
    return 1
fi

# Create csync alias that uses uv run
alias csync="cd $CONFIGS_DIR/csync && uv run python $CONFIGS_DIR/csync.py"

# For convenience, also keep the old sync.sh available
alias sync-old="$CONFIGS_DIR/sync.sh"