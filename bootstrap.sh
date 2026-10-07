#!/usr/bin/env bash

set -uo pipefail

readonly REPO_URL="https://github.com/oscariquelme01/Dotfiles.git"
readonly DOTFILES_DIR="$HOME/.dotfiles"
readonly RESOURCES_DIR="$HOME/.config/dotfiles"
readonly PERSONAL_REPO_URL="https://github.com/oscariquelme01/personal-dotfiles.git"
readonly PERSONAL_DIR="$HOME/.local/share/personal-dotfiles"
readonly BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
readonly NVIM_TAG="v0.12.0"

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
    local previous_name previous_email

    if [[ ! -d "$DOTFILES_DIR" ]]; then
        info "Cloning the dotfiles repository"
        git clone --bare "$REPO_URL" "$DOTFILES_DIR" || die "Could not clone $REPO_URL"
        fresh_clone=true
    fi

    if [[ "$fresh_clone" == true ]]; then
        previous_name=$(git config --global --includes --get user.name 2>/dev/null) || previous_name=""
        previous_email=$(git config --global --includes --get user.email 2>/dev/null) || previous_email=""
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

    if [[ "$fresh_clone" == true ]]; then
        if [[ -n "$previous_name" ]]; then
            git config --file="$HOME/.gitconfig.local" user.name "$previous_name" || die "Could not preserve Git name"
        fi
        if [[ -n "$previous_email" ]]; then
            git config --file="$HOME/.gitconfig.local" user.email "$previous_email" || die "Could not preserve Git email"
        fi
    fi

    if [[ -d "$BACKUP_DIR" ]]; then
        info "Conflicting files were backed up to $BACKUP_DIR"
    fi
}

install_neovim() (
    # Subshell keeps the cleanup trap and build environment local to this step.
    local prefix="$HOME/.local/opt/neovim/$NVIM_TAG"
    local launcher="$HOME/.local/bin/nvim"
    local build_dir tool version

    version=$("$prefix/bin/nvim" --version 2>/dev/null) || version=""
    if [[ -f "$prefix/.bootstrap-complete" && "${version%%$'\n'*}" == "NVIM $NVIM_TAG" ]]; then
        info "Neovim $NVIM_TAG is already installed; skipping the build"
    else
        for tool in git make cmake ninja cc c++; do
            command -v "$tool" &>/dev/null || {
                warn "Cannot build Neovim: missing $tool"
                return 1
            }
        done

        build_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-neovim.XXXXXX") || return 1
        trap 'rm -rf -- "$build_dir"' EXIT

        info "Building Neovim $NVIM_TAG from source"
        git clone --depth=1 --branch "$NVIM_TAG" \
            https://github.com/neovim/neovim.git "$build_dir/source" || return 1
        git -C "$build_dir/source" checkout --detach "refs/tags/$NVIM_TAG" || return 1
        make -C "$build_dir/source" CMAKE_BUILD_TYPE=Release \
            "CMAKE_INSTALL_PREFIX=$prefix" || return 1

        # Preserve an incomplete or unmanaged installation before replacing it.
        if [[ -e "$prefix" || -L "$prefix" ]]; then
            mkdir -p "$BACKUP_DIR/.local/opt/neovim" || return 1
            mv -T -- "$prefix" "$BACKUP_DIR/.local/opt/neovim/$NVIM_TAG" || return 1
        fi
        cmake --install "$build_dir/source/build" || return 1

        version=$("$prefix/bin/nvim" --version) || return 1
        [[ "${version%%$'\n'*}" == "NVIM $NVIM_TAG" ]] || return 1
        # Check the installed runtime without loading personal config or plugins.
        "$prefix/bin/nvim" --headless -u NONE -i NONE \
            '+lua if vim.fn.filereadable(vim.env.VIMRUNTIME .. "/doc/help.txt") ~= 1 then vim.cmd("cquit 1") end' \
            +qa || return 1
        touch "$prefix/.bootstrap-complete" || return 1
    fi

    mkdir -p "$HOME/.local/bin" || return 1
    if [[ -e "$launcher" || -L "$launcher" ]]; then
        if [[ -L "$launcher" && $(readlink "$launcher") == "$prefix/bin/nvim" ]]; then
            return 0
        fi
        mkdir -p "$BACKUP_DIR/.local/bin" || return 1
        mv -T -- "$launcher" "$BACKUP_DIR/.local/bin/nvim" || return 1
    fi
    ln -s "$prefix/bin/nvim" "$launcher"
)

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
    [[ -d "$zsh_custom/plugins/zsh-vi-mode" ]] || \
        git clone --depth=1 https://github.com/jeffreytse/zsh-vi-mode.git "$zsh_custom/plugins/zsh-vi-mode" || \
        FAILED+=("zsh-vi-mode")
    [[ -d "$zsh_custom/plugins/zsh-autopair" ]] || \
        git clone --depth=1 https://github.com/hlissner/zsh-autopair.git "$zsh_custom/plugins/zsh-autopair" || \
        FAILED+=("zsh-autopair")
}

prepare_personal_repo() {
    local origin
    [[ "$PERSONAL_DIR" == /* ]] || {
        warn "PERSONAL_DIR must be an absolute path."
        return 1
    }
    if [[ -e "$PERSONAL_DIR" || -L "$PERSONAL_DIR" ]]; then
        [[ -e "$PERSONAL_DIR/.git" ]] || return 1
        origin=$(git -C "$PERSONAL_DIR" remote get-url origin) || return 1
        case "$origin" in
            "$PERSONAL_REPO_URL"|git@github.com:oscariquelme01/personal-dotfiles.git) ;;
            *) warn "Unexpected personal repository origin: $origin"; return 1 ;;
        esac
        # This checkout is editable runtime configuration, not a disposable cache.
        info "Reusing $PERSONAL_DIR without pulling or changing local edits"
    else
        mkdir -p "$(dirname "$PERSONAL_DIR")" || return 1
        git clone "$PERSONAL_REPO_URL" "$PERSONAL_DIR" || return 1
    fi
    [[ -f "$PERSONAL_DIR/packages.txt" && -f "$PERSONAL_DIR/git/gitconfig.personal" ]]
}

choose_personal_setup() {
    local package
    ask "Fetch optional personal applications and Git configuration?" || return 0
    if ! prepare_personal_repo; then
        FAILED+=("personal-dotfiles clone/update")
        return
    fi

    info "Optional personal applications"
    while IFS= read -r package; do
        if [[ "$package" == mailspring-bin ]]; then
            printf '  - Mailspring with the Vesper Theme (%s)\n' "$package"
        else
            printf '  - %s\n' "$package"
        fi
    done < <(read_packages "$PERSONAL_DIR/packages.txt")
    ask "Install the applications listed above?" && INSTALL_PERSONAL_APPS=true
    ask "Install Oscar's personal and per-organization Git configuration?" && INSTALL_PERSONAL_GIT=true
    return 0
}

deploy_personal_directory() {
    local source="$1" destination="$2" backup
    [[ -d "$source" ]] || return 1
    source=$(realpath -- "$source") || return 1
    if [[ -L "$destination" && $(realpath -- "$destination") == "$source" ]]; then
        return 0
    fi
    if [[ -e "$destination" || -L "$destination" ]]; then
        mkdir -p "$BACKUP_DIR" || return 1
        backup=$(mktemp -d "$BACKUP_DIR/personal.XXXXXX") || return 1
        mv -T -- "$destination" "$backup/$(basename "$destination")" || return 1
        info "Backed up $destination to $backup"
    fi
    mkdir -p "$(dirname "$destination")" || return 1
    ln -sT -- "$source" "$destination"
}

configure_local_git() {
    local local_config="$HOME/.gitconfig.local"
    local personal_config="$HOME/.config/git/personal/gitconfig.personal"
    local legacy status include_file

    git config --file="$local_config" split-diffs.theme-directory "$HOME/.config/git-split-diffs/themes/" || return 1
    git config --file="$local_config" split-diffs.theme-name vesper || return 1

    if [[ "$INSTALL_PERSONAL_GIT" == true ]]; then
        deploy_personal_directory "$PERSONAL_DIR/git" "$HOME/.config/git/personal" || return 1
        # Remove only our own includes, then append the deployed identity last.
        for legacy in "$HOME/.config/dotfiles/personal/git/gitconfig.personal" \
            '~/.config/dotfiles/personal/git/gitconfig.personal' \
            "$personal_config" '~/.config/git/personal/gitconfig.personal'; do
            git config --file="$local_config" --fixed-value --unset-all include.path "$legacy"
            status=$?
            [[ $status == 0 || $status == 5 ]] || return 1
        done
        include_file=$(mktemp) || return 1
        if ! git config --file="$include_file" include.path "$personal_config" || \
            ! { printf '\n'; cat "$include_file"; } >> "$local_config"; then
            rm -f "$include_file"
            return 1
        fi
        rm -f "$include_file"
    fi
    return 0
}

install_mail_vesper_theme() {
    local source="$PERSONAL_DIR/mailspring/vesper-theme"
    local destination="$HOME/.config/Mailspring/packages/mailspring-theme-vesper"

    [[ -d "$source" ]] || {
        FAILED+=("Vesper Theme source")
        return
    }

    deploy_personal_directory "$source" "$destination" || {
        FAILED+=("Vesper Theme")
        return
    }

    info "Vesper Theme installed. Select it in Mailspring under Preferences → Appearance."
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

    command -v git &>/dev/null || \
        sudo pacman -S --needed --noconfirm git || die "Git is required to clone the dotfiles repository."

    checkout_dotfiles
    choose_personal_setup

    info "Installing core Arch dependencies"
    install_pacman_manifest "$RESOURCES_DIR/packages/core-pacman.txt"
    install_aur_manifest "$RESOURCES_DIR/packages/core-aur.txt"

    if [[ "$INSTALL_PERSONAL_APPS" == true ]]; then
        info "Installing optional personal applications"
        install_aur_manifest "$PERSONAL_DIR/packages.txt"
        if read_packages "$PERSONAL_DIR/packages.txt" | grep -Fxq mailspring-bin; then
            install_mail_vesper_theme
        fi
    fi

    install_shell_plugins
    mkdir -p "$HOME/.local/share/kitty/sessions" || FAILED+=("Kitty sessions directory")
    configure_local_git || FAILED+=("local/personal Git configuration")
    # Build only after all requested package installations have been attempted.
    install_neovim || FAILED+=("Neovim $NVIM_TAG source build/install")
    print_summary
    ((${#FAILED[@]} == 0))
}

main "$@"
