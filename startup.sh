#!/bin/bash

# Install jq
if ! command -v jq &> /dev/null; then
    sudo apt install -y jq
fi

# Install unzip
if ! command -v unzip &> /dev/null; then
    sudo apt install -y zip
fi

# Install AWS CLI
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

# Install Terraform
if ! command -v terraform &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install -y terraform
fi

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
    sudo usermod -aG docker $USER
    newgrp docker
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
