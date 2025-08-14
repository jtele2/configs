#!/usr/bin/env bash
# Setup script for Oh My Zsh custom plugins that require git cloning

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PLUGINS_DIR="${SCRIPT_DIR}/zsh_custom/plugins"

echo -e "${GREEN}Setting up Oh My Zsh custom plugins...${NC}"

# Create plugins directory if it doesn't exist
mkdir -p "${PLUGINS_DIR}"

# Create a temporary directory for cloning
TMP_DIR=$(mktemp -d)
trap "rm -rf ${TMP_DIR}" EXIT

# autoswitch_virtualenv plugin
AUTOSWITCH_DIR="${PLUGINS_DIR}/autoswitch_virtualenv"
if [ -d "${AUTOSWITCH_DIR}" ]; then
    echo -e "${YELLOW}autoswitch_virtualenv already installed, updating...${NC}"
    # Remove old version
    rm -rf "${AUTOSWITCH_DIR}"
fi

echo -e "${GREEN}Installing autoswitch_virtualenv...${NC}"
# Clone to temp directory
git clone https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git "${TMP_DIR}/autoswitch_virtualenv"

# Copy files without .git directory
mkdir -p "${AUTOSWITCH_DIR}"
rsync -av --exclude='.git' --exclude='.github' --exclude='.gitignore' "${TMP_DIR}/autoswitch_virtualenv/" "${AUTOSWITCH_DIR}/"

echo -e "${GREEN}✓ Plugin setup complete!${NC}"
echo -e "${YELLOW}Note: Make sure to restart your shell or run 'source ~/.zshrc' to load the plugins.${NC}"