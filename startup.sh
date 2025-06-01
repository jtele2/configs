#!/bin/bash

# TODO: Finish this file

# Install jq
brew install jq

# Install unzip
brew install unzip

# Install AWS CLI
brew install awscli

# Install docker
brew install docker

# Softlink the required files
ln -sf $HOME/configs/.zshrc $HOME/.zshrc
ln -sf $HOME/configs/functions.zsh $HOME/.oh-my-zsh/custom/functions.zsh
ln -sf $HOME/configs/aliases.zsh $HOME/.oh-my-zsh/custom/aliases.zsh

# Setup git
git config --global user.name "Josiah M. Caprino"
git config --global user.email "josiah.caprino@ecstech.com"
