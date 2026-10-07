#!/usr/bin/env bash

set -uo pipefail

readonly REPO_URL="https://github.com/oscariquelme01/the-dotfiles.git"
readonly DOTFILES_DIR="$HOME/.dotfiles"
readonly RESOURCES_DIR="$HOME/.config/dotfiles"
readonly BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

FAILED=()
INSTALL_PERSONAL_APPS=false
INSTALL_PERSONAL_GIT=false

info() {
    printf '\n\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
    printf '\033[1;33mWarning:\033[0m %s\n' "$*" >&2
}

die() {
    printf '\033[1;31mError:\033[0m %s\n' "$*" >&2
    exit 1
}

ask() {
    local prompt="$1"
    local answer

    if [[ ! -r /dev/tty ]]; then
        warn "No interactive terminal is available; answering no to: $prompt"
        return 1
    fi

    printf '%s [y/N] ' "$prompt" > /dev/tty
    IFS= read -r answer < /dev/tty || return 1
    [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

read_packages() {
    local manifest="$1"
    sed -E 's/[[:space:]]*#.*$//; /^[[:space:]]*$/d' "$manifest"
}

dotfiles() {
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

install_pacman_manifest() {
    local manifest="$1"
    local package
    local -a packages=()

    [[ -f "$manifest" ]] || {
        FAILED+=("missing manifest: $manifest")
        return
    }

    mapfile -t packages < <(read_packages "$manifest")
    ((${#packages[@]})) || return

    if sudo pacman -S --needed --noconfirm "${packages[@]}"; then
        return
    fi

    warn "The grouped pacman install failed; retrying packages individually."
    for package in "${packages[@]}"; do
        pacman -Q "$package" &>/dev/null && continue
        sudo pacman -S --needed --noconfirm "$package" || FAILED+=("pacman: $package")
    done
}

ensure_yay() {
    local build_dir

    command -v yay &>/dev/null && return 0

    info "Installing yay"
    sudo pacman -S --needed --noconfirm base-devel git || return 1
    build_dir="$(mktemp -d)" || return 1

    if ! git clone https://aur.archlinux.org/yay.git "$build_dir/yay"; then
        rm -rf "$build_dir"
        return 1
    fi

    if ! (cd "$build_dir/yay" && makepkg -si --needed --noconfirm); then
        rm -rf "$build_dir"
        return 1
    fi

    rm -rf "$build_dir"
}

install_aur_manifest() {
    local manifest="$1"
    local package
    local -a packages=()

    [[ -f "$manifest" ]] || {
        FAILED+=("missing manifest: $manifest")
        return
    }

    mapfile -t packages < <(read_packages "$manifest")
    ((${#packages[@]})) || return

    if ! ensure_yay; then
        warn "Could not install yay; skipping AUR packages."
        for package in "${packages[@]}"; do
            pacman -Q "$package" &>/dev/null || FAILED+=("AUR: $package")
        done
        return
    fi

    if yay -S --needed --noconfirm "${packages[@]}"; then
        return
    fi

    warn "The grouped AUR install failed; retrying packages individually."
    for package in "${packages[@]}"; do
        pacman -Q "$package" &>/dev/null && continue
        yay -S --needed --noconfirm "$package" || FAILED+=("AUR: $package")
    done
}

checkout_dotfiles() {
    local path
    local source
    local destination
    local fresh_clone=false

    if [[ ! -d "$DOTFILES_DIR" ]]; then
        info "Cloning the dotfiles repository"
        git clone --bare "$REPO_URL" "$DOTFILES_DIR" || die "Could not clone $REPO_URL"
        fresh_clone=true
    fi

    if [[ "$fresh_clone" == true ]]; then
        while IFS= read -r path; do
            source="$HOME/$path"
            [[ -e "$source" || -L "$source" ]] || continue

            destination="$BACKUP_DIR/$path"
            mkdir -p "$(dirname "$destination")" || die "Could not create the backup directory"
            mv -- "$source" "$destination" || die "Could not back up $source"
        done < <(dotfiles ls-tree -r --name-only HEAD)
    fi

    dotfiles checkout || die "Could not check out the dotfiles"
    dotfiles config --local status.showUntrackedFiles no

    if [[ -d "$BACKUP_DIR" ]]; then
        info "Conflicting files were backed up to $BACKUP_DIR"
    fi
}

install_shell_plugins() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    info "Installing shell plugins"
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" || \
            FAILED+=("Oh My Zsh")
    fi

    mkdir -p "$zsh_custom/plugins"
    [[ -d "$zsh_custom/plugins/zsh-autosuggestions" ]] || \
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions" || \
        FAILED+=("zsh-autosuggestions")
    [[ -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]] || \
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting" || \
        FAILED+=("zsh-syntax-highlighting")
    [[ -d "$zsh_custom/plugins/zsh-fzf-history-search" ]] || \
        git clone --depth=1 https://github.com/joshskidmore/zsh-fzf-history-search "$zsh_custom/plugins/zsh-fzf-history-search" || \
        FAILED+=("zsh-fzf-history-search")
}

configure_local_git() {
    local local_config="$HOME/.gitconfig.local"
    local personal_config="$HOME/.config/dotfiles/personal/git/gitconfig.personal"

    git config --file="$local_config" split-diffs.theme-directory "$HOME/.config/git-split-diffs/themes/"
    git config --file="$local_config" split-diffs.theme-name vesper

    if [[ "$INSTALL_PERSONAL_GIT" == true ]]; then
        if ! git config --file="$local_config" --get-all include.path 2>/dev/null | \
            grep -Fxq "$personal_config"; then
            git config --file="$local_config" --add include.path "$personal_config"
        fi
    fi
}

install_vespere_theme() {
    local source="$RESOURCES_DIR/personal/mailspring/vespere-theme"
    local destination="$HOME/.config/Mailspring/packages/mailspring-theme-vespere"

    [[ -d "$source" ]] || {
        FAILED+=("Vespere Theme source")
        return
    }

    mkdir -p "$destination"
    cp -a "$source/." "$destination/" || {
        FAILED+=("Vespere Theme")
        return
    }

    info "Vespere Theme installed. Select it in Mailspring under Preferences → Appearance."
}

print_summary() {
    local failure

    info "Bootstrap complete"
    if ((${#FAILED[@]})); then
        warn "Some dependencies or setup steps still need attention:"
        for failure in "${FAILED[@]}"; do
            printf '  - %s\n' "$failure" >&2
        done
    else
        printf 'All requested packages and configuration were installed successfully.\n'
    fi

    printf '\nBefore rebooting, review and enable the Noctalia greeter/greetd setup manually.\n'
}

main() {
    [[ -f /etc/arch-release ]] || die "This bootstrap currently supports Arch Linux only."
    command -v pacman &>/dev/null || die "pacman is required."
    [[ $EUID -ne 0 ]] || die "Run this script as a regular user, not as root."

    cat <<'EOF'

Optional personal applications:
  - Mailspring with the Vespere Theme
EOF
    ask "Install the personal applications listed above?" && INSTALL_PERSONAL_APPS=true
    ask "Install Oscar's personal and per-organization Git configuration?" && INSTALL_PERSONAL_GIT=true

    command -v git &>/dev/null || \
        sudo pacman -S --needed --noconfirm git || die "Git is required to clone the dotfiles repository."

    checkout_dotfiles

    info "Installing core Arch dependencies"
    install_pacman_manifest "$RESOURCES_DIR/packages/core-pacman.txt"
    install_aur_manifest "$RESOURCES_DIR/packages/core-aur.txt"

    if [[ "$INSTALL_PERSONAL_APPS" == true ]]; then
        info "Installing optional personal applications"
        install_aur_manifest "$RESOURCES_DIR/packages/personal-apps.txt"
        install_vespere_theme
    fi

    install_shell_plugins
    configure_local_git
    print_summary
}

main "$@"
