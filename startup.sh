#!/bin/bash
# Setting up an Ubuntu Instance
set -e -x

DIR=/home/ubuntu

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
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/home/ubuntu/awscliv2.zip"
        unzip $DIR/awscliv2.zip
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
    apt-get update && apt-get install -y zsh wget # Install zsh and wget
    # Install oh-my-zsh
    wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O $DIR/install.sh
    chown -R ubuntu:ubuntu $DIR/install.sh
    cd $DIR
    echo pwd
    if [ ! -d "$DIR/.oh-my-zsh" ]; then
        runuser -l ubuntu -c 'sh install.sh'
    else
        echo "oh-my-zsh is already installed"
    fi
    # Change the default shell to zsh
    chsh -s /usr/bin/zsh ubuntu
    rm -rf install.sh

}

setup_dotfiles () {

    echo "SETTING UP DOTFILES..."
    git clone https://github.com/jtele2/configs.git $DIR/configs
    ln -sf $DIR/configs/.vimrc $DIR/.vimrc
    ln -sf $DIR/configs/.zshrc $DIR/.zshrc
    ln -sf $DIR/configs/functions.zsh $DIR/.oh-my-zsh/custom/functions.zsh
    ln -sf $DIR/configs/aliases.zsh $DIR/.oh-my-zsh/custom/aliases.zsh
    cp -asf $DIR/configs/completions $DIR/.zsh
    chown -R ubuntu:ubuntu $DIR/configs $DIR/.vimrc $DIR/.zshrc $DIR/.oh-my-zsh/custom/functions.zsh /home/ubuntu/.oh-my-zsh/custom/aliases.zsh /home/ubuntu/.zsh

}

# Check if a function name is passed as an argument
if declare -f "$1" > /dev/null
then
    # Call the function passed as an argument
    "$@"
else
    # Call all the functions
    setup_jq
    setup_unzip
    setup_aws
    setup_fzf
    setup_trashcli
    setup_zsh
    setup_dotfiles
fi