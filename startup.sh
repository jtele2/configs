#!/bin/bash

# Install zsh and trash-cli
if ! command -v zsh &> /dev/null; then
    sudo apt install -y zsh
fi
if ! command -v trash-put &> /dev/null; then
    sudo apt install -y trash-cli
fi

# Install docker
if ! command -v docker &> /dev/null; then
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
fi

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # Control will enter here if $DIRECTORY exists.
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Softlink the required files
ln -sf $HOME/configs/.zshrc $HOME/.zshrc
ln -sf $HOME/configs/functions.zsh $HOME/.oh-my-zsh/custom/functions.zsh
ln -sf $HOME/configs/aliases.zsh $HOME/.oh-my-zsh/custom/aliases.zsh
ln -sf $HOME/configs/.vimrc $HOME/.vimrc

# Setup git
git config --global user.name "Josiah M. Caprino"
git config --global user.email "josiah.caprino@ecstech.com"
