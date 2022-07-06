#!/bin/bash

# Run this from the configs repo

sudo apt install zsh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Use my .zshrc config
ln -sf ~/configs/.zshrc ~/.zshrc

