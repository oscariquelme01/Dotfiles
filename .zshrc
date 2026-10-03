export XDG_CONFIG_HOME="$HOME/.config"

# ---- .oh-my-zsh (cross platform) ----
export ZSH="$HOME/.oh-my-zsh"
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting zsh-fzf-history-search zsh-vi-mode zsh-autopair)
source $ZSH/oh-my-zsh.sh

# Restore autopair bindings after zsh-vi-mode's deferred initialization.
zvm_after_init_commands+=(autopair-init)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#888888'
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_VI_HIGHLIGHT_BACKGROUND=red             # Color name

# ---- PATH ----
export PATH="$PATH:$HOME/.local/bin"

# ---- nvm (paths differ per platform) ----
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ---- Keybindings ----
# bindkey -v 
bindkey '^[0c' forward-word
bindkey '^[0d' backward-word

# ---- Aliases ----
alias ls="lsd"
alias v="nvim"
alias o="opencode"
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
# alias cat='bat'

# ---- Tools ----
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
export EDITOR="nvim"
source <(fzf --zsh)
