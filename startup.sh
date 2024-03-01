#!/bin/bash
# Setting up an Ubuntu Instance
set -e -x

DIR=/home/ubuntu


setup_jq() {

  echo "=================SETTING UP JQ================="
  if ! command -v jq &> /dev/null; then
      apt install -y -qq jq
  else
      echo "jq already installed"
  fi

}


setup_unzip() {

    echo "=================SETTING UP UNZIP================="
    if ! command -v unzip &> /dev/null; then
        apt install -y -qq zip
    fi

}


setup_aws() {

    echo "=================SETTING UP AWS================="
    if ! command -v aws &> /dev/null; then
        curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/home/ubuntu/awscliv2.zip"
        unzip -qq $DIR/awscliv2.zip
        ./aws/install
        rm -rf aws
    fi

}


setup_fzf() {

    echo "=================SETTING UP FZF================="
    apt-get install -y -qq fzf
    if command -v fzf >/dev/null 2>&1; then
        echo "fzf successfully installed"
    else
        echo "fzf installation failed"
        exit 1
    fi

}


setup_zsh() {

    echo "=================SETTING UP ZSH================="
    apt-get install -y -qq zsh wget
    # Install oh-my-zsh
    wget -q https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O $DIR/install.sh
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


setup_trashcli() {
    
    echo "=================SETTING UP TRASH-CLI================="
    if ! command -v trash-put &> /dev/null; then
        apt install -y -qq trash-cli
    fi
    
}


setup_dotfiles() {

    echo "=================SETTING UP DOTFILES================="
    if [ ! -d "$DIR/configs" ]; then
        git clone https://github.com/jtele2/configs.git $DIR/configs
    else
        echo "configs dir already exists"
    fi
    ln -sf $DIR/configs/.vimrc $DIR/.vimrc
    ln -sf $DIR/configs/.zshrc $DIR/.zshrc
    ln -sf $DIR/configs/functions.zsh $DIR/.oh-my-zsh/custom/functions.zsh
    ln -sf $DIR/configs/aliases.zsh $DIR/.oh-my-zsh/custom/aliases.zsh
    cp -asf $DIR/configs/completions $DIR/.zsh
    chown -R ubuntu:ubuntu $DIR
    # chown -R ubuntu:ubuntu $DIR/configs $DIR/.vimrc $DIR/.zshrc $DIR/.oh-my-zsh/custom/functions.zsh $DIR/.oh-my-zsh/custom/aliases.zsh $DIR/.zsh

}

setup_acg_practic_repo() {

    echo "=================SETTING UP ACG PRACTICE REPO================="
    if [ ! -d "$DIR/acg" ]; then
        git clone https://github.com/jtele2/acg-practice.git $DIR/acg
    else
        echo "acg dir already exists"
    fi
    chown -R ubuntu:ubuntu $DIR/acg

}

setup_packages() {

    echo "=================SETTING UP PACKAGES================="
    apt-get install -y -qq python3-pip python3-venv
    pip3 install -U pip setuptools
    pip3 install boto3 black isort requests tqdm

}


apt-get update -qq

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
    setup_zsh
    setup_trashcli
    setup_dotfiles
    setup_acg_practic_repo
    setup_packages
fi