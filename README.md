# Zsh Dotfiles

Personal Zsh configuration with Oh My Zsh, custom themes, and development tool completions.

## Quick Setup

Prerequisites: Install [Zsh](https://www.zsh.org/) and [Oh My Zsh](https://ohmyz.sh/).

```bash
# Clone repository
git clone https://github.com/jtele2/configs ~/configs

# Symlink the zshrc file
ln -sf ~/configs/zshrc ~/.zshrc

# Optional: Symlink other configs
ln -sf ~/configs/direnvrc ~/.direnvrc
```

That's it! The `.zshrc` file automatically points Oh My Zsh to use the custom directory in this repo.

## Contents

- **zshrc** - Main Zsh configuration file
- **zsh_custom/** - Oh My Zsh customizations
  - **completions/** - Shell completions (eksctl, kind, kustomize, ripgrep)
  - **themes/** - Custom themes (custom-bira)
  - **plugins/** - Custom plugins
  - Git prompt patches
- **k9s/** - Kubernetes CLI configuration
- **direnvrc** - direnv configuration
- **ZSH.md** - Zsh quick reference guide

## Customization

- Edit `zshrc` to modify plugins, aliases, or settings
- Add your own completions to `zsh_custom/completions/`
- Create local overrides in `~/.zshrc.local` (automatically sourced if it exists)

## Zsh Startup Order

**Login Shell:** `/etc/zshenv` → `~/.zshenv` → `/etc/zprofile` → `~/.zprofile` → `/etc/zshrc` → `~/.zshrc` → `/etc/zlogin` → `~/.zlogin`

**Interactive Shell:** `/etc/zshenv` → `~/.zshenv` → `/etc/zshrc` → `~/.zshrc`
