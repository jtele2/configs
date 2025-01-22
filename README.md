# Joe Caprino's Configs

These configs work for zsh with oh-my-zsh. Everything needs a simlink.

The `.zshenv` loads the completions outside of zsh plugins.

`fpath` is for completion loading, `path` is for PATH.

## Installation

Install zsh and oh-my-zsh prior to using these configs. Symlink the following:  

```bash
cp -asf /home/ubuntu/configs/completions /home/ubuntu/.zsh
ln -sf /home/ubuntu/configs/.vimrc /home/ubuntu/.vimrc
ln -sf /home/ubuntu/configs/.zshenv /home/ubuntu/.zshenv
ln -sf /home/ubuntu/configs/.zshrc /home/ubuntu/.zshrc
ln -sf /home/ubuntu/configs/aliases.zsh /home/ubuntu/.oh-my-zsh/custom/aliases.zsh
ln -sf /home/ubuntu/configs/functions.zsh /home/ubuntu/.oh-my-zsh/custom/functions.zsh
ln -sf /home/ubuntu/configs/ys.zsh-theme /home/ubuntu/.oh-my-zsh/custom/themes/ys.zsh-theme
```

## Path Notes

When Zsh starts, it runs configuration files in the following order, depending on the shell type.
For a Login Shell:

1. /etc/zshenv: System-wide environment variables and configurations.
2. ~/.zshenv: User-specific environment variables.
3. /etc/zprofile: System-wide login-specific configurations.
4. ~/.zprofile: User-specific login configurations.
5. /etc/zshrc: System-wide interactive shell configurations.
6. ~/.zshrc: User-specific interactive shell configurations.
7. /etc/zlogin: System-wide login tasks.
8. ~/.zlogin: User-specific login tasks.

For a Non-Login Interactive Shell:

1. /etc/zshenv
2. ~/.zshenv
3. /etc/zshrc
4. ~/.zshrc
