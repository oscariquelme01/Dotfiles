export XDG_CONFIG_HOME="$HOME/.config"

# ---- Platform detection ----
case "$OSTYPE" in
    darwin*) IS_MAC=1 ;;
    linux*)  IS_LINUX=1 ;;
esac
#
# ---- Homebrew (macOS only) ----
if [[ -n "$IS_MAC" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ---- .oh-my-zsh (cross platform) ----
export ZSH="$HOME/.oh-my-zsh"
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting zsh-fzf-history-search)
source $ZSH/oh-my-zsh.sh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#888888'

# ---- PATH ----
export PATH="$PATH:$HOME/.local/bin"

# ---- nvm (paths differ per platform) ----
export NVM_DIR="$HOME/.nvm"
if [[ -n "$IS_MAC" ]]; then
    [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
    [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
else
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# ---- Keybindings ----
bindkey -v 
bindkey '^[0c' forward-word
bindkey '^[0d' backward-word
# bindkey '^R' fzf-history-widget

# ---- Aliases ----
alias ls="lsd"
alias v="nvim"
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
# alias cat='bat'

# ---- Tools ----
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
export EDITOR="nvim"
source <(fzf --zsh)

# Git diff for a specific commit (picked up by .gitconfig)
gitchanged ()
{
    git diff $1~ $1
}

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/home/topi/.bun/_bun" ] && source "/home/topi/.bun/_bun"
