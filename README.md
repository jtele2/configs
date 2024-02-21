# Configs

These configs work for zsh with oh-my-zsh. Everything needs a simlink.

The `.zshenv` loads the completions outside of zsh plugins.

`fpath` is for completion loading, `path` is for PATH. 

## Installation for Ubuntu

Install zsh and oh-my-zsh prior to using these configs. Symlink the following:  

```bash
cp -asf /home/ubuntu/configs/completions /home/ubuntu/.zsh
ln -sf /home/ubuntu/configs/.vimrc /home/ubuntu/.vimrc
ln -sf /home/ubuntu/configs/.zshenv /home/ubuntu/.zshenv
ln -sf /home/ubuntu/configs/.zshrc /home/ubuntu/.zshrc
ln -sf /home/ubuntu/configs/aliases.zsh /home/ubuntu/.oh-my-zsh/custom/aliases.zsh
ln -sf /home/ubuntu/configs/functions.zsh /home/ubuntu/.oh-my-zsh/custom/functions.zsh
```

## Installation for MacBook Pro

Install zsh and oh-my-zsh prior to using these configs. Symlink the following:  

```bash
# TODO
```