# Zsh Configuration for Linux Systems and Development Environments

This repository provides a custom Zsh configuration designed for Linux systems, development environments, and infrastructure workflows. The goal is to offer a fast, minimal, and maintainable shell setup that can be easily deployed across multiple machines.

## Overview

The configuration focuses on performance, modularity, and simplicity. It avoids unnecessary complexity and heavy frameworks in favor of a direct and transparent setup that can be fully understood and modified by the user.

It is intended for users who work frequently in the terminal, particularly in system administration, networking, and software development contexts.

## Features

- Optimized Zsh startup performance with minimal overhead
- Custom prompt designed for readability and context awareness
- Integrated shell enhancements (autosuggestions, syntax highlighting, improved completion)
- Portable setup that can be replicated across different machines
- Minimal dependency approach to maintain control over the shell environment

- ## Installation (User home folder)

This configuration is **personal** and should be installed in the user home folder.

### 1) Backup your current config (recommended)

```bash
cp ~/.zshrc ~/.zshrc.backup 2>/dev/null || true
```

### 2) Clone the repository (anywhere you prefer)
```
git clone https://github.com/REFTA613/zsh-config.git ~/zsh-config
```

### 3) Install the .zshrc in your home folder

Option A (simple copy):
```
cp ~/zsh-config/.zshrc ~/.zshrc
```
Option B (recommended symlink):
```
ln -sf ~/zsh-config/.zshrc ~/.zshrc
```
### 4) Reload Zsh
```
exec zsh
```


### Parte 3/4 (Markdown — pacchetti + yay)

```md
```
## Required Packages (Arch Linux)

### Official repositories

```bash
sudo pacman -Syu --needed zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting grc
```

> **Performance note:** if your shell freezes/lag while typing, consider using `zsh-fast-syntax-highlighting` (AUR) and avoid heavy completion UI plugins (see below).

## AUR (Arch Linux) - Install `yay`

Some optional performance packages are provided via the AUR.

### 1) Install build dependencies

```bash
sudo pacman -Syu --needed base-devel git
```

### 2) Build and install `yay`

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

Verify:

```bash
yay --version
```
## Optional (Recommended) - Faster syntax highlighting (AUR)

On slower CPUs, `zsh-fast-syntax-highlighting` is often smoother than `zsh-syntax-highlighting`.

Install:

```bash
yay -S --needed zsh-fast-syntax-highlighting
# alternative:
# yay -S --needed zsh-fast-syntax-highlighting-git
```

### Enable it in `.zshrc` (plugin block example)

Add this to your `.zshrc` (syntax highlighting should be loaded last):

```zsh
# zsh-autosuggestions (async, helps reduce freezes)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# prefer fast-syntax-highlighting (AUR), fallback to zsh-syntax-highlighting
if [[ -r /usr/share/zsh/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
elif [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
```

## Notes about freezes / lag while typing (important)

If you experience freezes while typing or when a completion menu appears under the cursor, the cause is usually a heavy interactive completion plugin (for example `zsh-autocomplete`) combined with syntax highlighting.

Recommended approach for performance:
- Prefer Zsh built-in completion (`compinit`) with cache
- Keep `zsh-autosuggestions` async
- Prefer `zsh-fast-syntax-highlighting` (AUR) on slower machines
- Avoid heavy live completion UI plugins if they cause lag

Example `compinit` with cache:

```zsh
autoload -Uz compinit
mkdir -p ~/.cache/zsh
compinit -d ~/.cache/zsh/zcompdump -C
```

If you see warnings like:
- `zsh-syntax-highlighting: unhandled ZLE widget '...'`

They are usually caused by other plugins defining custom ZLE widgets. Disabling the heavy completion plugin typically removes both the warnings and the lag.
