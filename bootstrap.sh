#!/usr/bin/env bash
set -e

# Clone if not already present
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone --bare git@github.com:YOU/dotfiles.git "$HOME/.dotfiles"
fi

dotfiles() {
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

# Checkout with backup
mkdir -p "$HOME/.dotfiles-backup"
dotfiles checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | \
    xargs -I{} sh -c 'mkdir -p "$HOME/.dotfiles-backup/$(dirname {})" && mv "$HOME/{}" "$HOME/.dotfiles-backup/{}"' || true
dotfiles checkout

# Bare repo config
dotfiles config --local status.showUntrackedFiles no

# git-split-diffs theme path (platform-agnostic via $HOME)
# This is required because node fs.open doesn't expand '~' and git doesn't support $HOME in config files
git config --file="$HOME/.gitconfig.local" split-diffs.theme-directory "$HOME/.config/git-split-diffs/themes/"
git config --file="$HOME/.gitconfig.local" split-diffs.theme-name "vesper"

# oh-my-zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-fzf-history-search" ] && \
    git clone https://github.com/joshskidmore/zsh-fzf-history-search ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search

# Alacritty platform symlink (Mac uses Raycast launcher, but just in case)
case "$OSTYPE" in
    darwin*) ln -sf "$HOME/.config/alacritty/platform.mac.toml" "$HOME/.config/alacritty/platform.toml" ;;
    linux*)  ln -sf "$HOME/.config/alacritty/platform.linux.toml" "$HOME/.config/alacritty/platform.toml" ;;
esac

echo "Bootstrap complete."
