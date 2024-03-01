# Configs

These configs work for zsh with oh-my-zsh. Everything needs a simlink.

The `.zshenv` loads the completions outside of zsh plugins.

`fpath` is for completion loading, `path` is for PATH. 

## Installation

Install zsh and oh-my-zsh prior to using these configs. Symlink the following:  

```bash
cp -asf $HOME/configs/completions $HOME/.zsh
ln -sf $HOME/configs/.vimrc $HOME/.vimrc
ln -sf $HOME/configs/.zshenv $HOME/.zshenv
ln -sf $HOME/configs/.zshrc $HOME/.zshrc
ln -sf $HOME/configs/aliases.zsh $HOME/.oh-my-zsh/custom/aliases.zsh
ln -sf $HOME/configs/functions.zsh $HOME/.oh-my-zsh/custom/functions.zsh
```

## Installation for MacBook Pro

Install zsh and oh-my-zsh prior to using these configs. Symlink the following:  

```bash
# TODO
```

## A Cloud Guru (ACG) Classes
  - A lot of this works for ACG classes. To launch my default instance, apply the terraform file. 
  - By default, it will launch an EC2 instance you can use for dev purposes. 
    - For updates to the pip packages available through `user data`, add them to the `startup.sh` 
      file in the `setup_packages()` function. 