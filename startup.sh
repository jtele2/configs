#!/bin/bash
# Setting up an Ubuntu Instance
set -e -x

setup_jq() {

  echo "SETTING UP JQ..."
  if ! command -v jq &> /dev/null; then
      sudo apt install -y jq
  else
      echo "jq already installed"
  fi

}


setup_unzip() {

    echo "SETTING UP UNZIP..."
    if ! command -v unzip &> /dev/null; then
        sudo apt install -y zip
    fi

}


setup_aws() {

    echo "SETTING UP AWS..."
    if ! command -v aws &> /dev/null; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/awscliv2.zip"
        unzip $HOME/awscliv2.zip
        sudo ./aws/install
        rm -rf aws
    fi

}


setup_fzf() {

    echo "SETTING UP FZF..."
    # Update package lists
    apt-get update
    # Install fzf
    apt-get install -y fzf
    # Verify installation
    if command -v fzf >/dev/null 2>&1; then
        echo "fzf successfully installed"
    else
        echo "fzf installation failed"
        exit 1
    fi

}


setup_trashcli() {
    
    echo "SETTING UP TRASH-CLI..."
    if ! command -v zsh &> /dev/null; then
        sudo apt install -y zsh
    fi
    if ! command -v trash-put &> /dev/null; then
        sudo apt install -y trash-cli
    fi
    
}

setup_zsh () {

    echo "SETTING UP ZSH..."
    local DIR=/home/ubuntu
    apt-get update && apt-get install -y zsh wget # Install zsh and wget
    # Install oh-my-zsh
    wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O $DIR/install.sh
    chown -R ubuntu:ubuntu $DIR/install.sh
    cd $DIR
    echo pwd
    runuser -l ubuntu -c 'sh install.sh'
    # Change the default shell to zsh
    yum -y install util-linux-user
    chsh -s /usr/bin/zsh ubuntu
    rm -rf install.sh

}

setup_dotfiles () {

    echo "SETTING UP DOTFILES..."
    git clone https://github.com/aws-samples/ec2-data-science-vim-tmux-zsh.git $HOME
    ln -sf $HOME/configs/.vimrc $HOME/.vimrc
    ln -sf $HOME/configs/.zshrc $HOME/.zshrc
    ln -sf $HOME/configs/functions.zsh $HOME/.oh-my-zsh/custom/functions.zsh
    ln -sf $HOME/configs/aliases.zsh $HOME/.oh-my-zsh/custom/aliases.zsh
    cp -asf $HOME/configs/completions $HOME/.zsh
    chown -R ubuntu:ubuntu $HOME/configs $HOME/.vimrc $HOME/.zshrc $HOME/.oh-my-zsh/custom/functions.zsh $HOME/.oh-my-zsh/custom/aliases.zsh $HOME/.zsh

}

# get_dotfiles
# setup_zsh

# Check if a function name is passed as an argument
if declare -f "$1" > /dev/null
then
  # Call the function passed as an argument
  "$@"
else
  echo "'$1' is not a known function name" >&2
  exit 1
fi