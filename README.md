# Dotfiles

My personal dotfiles!! Featuring [the very beautiful vesper theme](https://github.com/vladzima/vesper-theme), a (hopefully manually portable to MacOS) terminal and development environment, plus an opinionated Arch Linux desktop built with [Hyprland](https://hyprland.org/) and [Noctalia](https://noctalia.dev/).

The repository is managed as a bare Git repository with `$HOME` as its work tree. Config files therefore live where the applications expect them—no dotfile manager and no symlink farm required.

## Setup overview

### Desktop

- [Hyprland](https://hyprland.org/) with a keyboard-first configuration
- [Noctalia](https://noctalia.dev/) for the bar and system UI: application launcher, notifications and DND, clipboard history, wallpaper management, screenshots, lock/logout controls, Polkit agent, and audio/network/Bluetooth/brightness controls
- Laptop-friendly behavior, including locking, idle handling, battery information, and brightness controls, plus an integrated Noctalia-native greeter that makes you forget you are using Arch BTW.

### Terminal and shell

- [Kitty](https://sw.kovidgoyal.net/kitty/) as the single terminal emulator
- Kitty splits, tabs, project sessions, custom tab bar, and a Vesper-inspired theme
- Seamless navigation between Kitty panes and Neovim
- Neovim-powered Kitty scrollback through [`kitty-scrollback.nvim`](https://github.com/mikesmithgh/kitty-scrollback.nvim)
- Zsh, Oh My Zsh, Starship, `fzf`, and `zoxide`

### Development tools

- Neovim `v0.12.0+`, organized into UI, navigation, editor, language, and integration modules
- LSP, Treesitter, completion, formatting, and linting for the languages I regularly use
- [`oil.nvim`](https://github.com/stevearc/oil.nvim) for file management and [`fzf-lua`](https://github.com/ibhagwan/fzf-lua) for finding things
- Kitty, Git and OpenCode integrations. (There is also a database integration but it is currently on Triage)
- [OpenCode](https://opencode.ai/) with Vim-style interaction & navigations
- [lazygit](https://github.com/jesseduffield/lazygit) and [git-split-diffs](https://github.com/banga/git-split-diffs) that look absolutely beautiful
- Optional personal and per-organization Git identities

## How the repository works

The Git directory lives at `~/.dotfiles`, while the work tree is `$HOME`:

```bash
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status
```

The shell config exposes that command through the `dotfiles` alias:

```bash
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

This lets tracked files remain in their normal locations, such as `~/.zshrc`, `~/.gitconfig`, and `~/.config/kitty/kitty.conf`.

The repository sets `status.showUntrackedFiles` to `no`; otherwise every untracked file in `$HOME` would appear in `dotfiles status`.

## Installation

### Bootstrap

On a fresh system:

```bash
curl -fsSL https://raw.githubusercontent.com/oscariquelme01/the-dotfiles/master/bootstrap.sh | bash
```

The bootstrap is responsible for repository setup and machine-specific configuration. It:

- clones the repository as a bare repo at `~/.dotfiles`
- backs up checkout conflicts under `~/.dotfiles-backup/`
- checks the tracked files out directly into `$HOME`
- configures the bare repository for a home-directory work tree
- writes machine-local paths that cannot be expressed portably in tracked config
- installs the external Zsh plugins used by `.zshrc`
- installs all the dependencies (or at least it tries!). It assumes we are working on Arch Linux with `pacman` and installs `yay` when AUR packages are needed.
    - if the script fails to install dependencies, the user will be notified with a list of packages that are still needed by the system
- shows the complete list of personal applications and asks whether to install them
- optionally enables my personal and per-organization Git configuration

The core setup includes Hyprland, Noctalia, Kitty, Zsh, Neovim, OpenCode, Git tooling, and their supporting packages. The package manifests under `~/.config/dotfiles/packages/` are the source of truth for what the bootstrap installs.

#### Optional personal setup

This is a personal repository, but most of the setup is reusable. The bootstrap therefore keeps the opinionated extras behind separate prompts. It currently offers:

- **Personal applications:** Mailspring with the **Vespere Theme**
- **Personal Git configuration:** my default identity and conditional identities for organization directories

Mailspring and its theme are one choice, not separate installations. Vespere is my Vesper-inspired fork of the [Sparky Mailspring Theme](https://github.com/siniux/Sparky-Mailspring-Theme), whose original layout and MIT license are retained.

The script asks again on every run; it does not maintain a separate selections file. Package installation and configuration steps are safe to rerun, and declining an option does not uninstall something selected during an earlier run.

### Manual repository setup

Clone the repository and define the helper alias:

```bash
git clone --bare git@github.com:oscariquelme01/the-dotfiles.git "$HOME/.dotfiles"
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

Attempt the checkout:

```bash
dotfiles checkout
```

If Git reports files that would be overwritten, move those files into `~/.dotfiles-backup/` while preserving their paths, then retry the checkout. Finally, hide unrelated files in `$HOME`:

```bash
dotfiles config --local status.showUntrackedFiles no
```

The alias is already included in the tracked `.zshrc`; start a new shell after checkout or source it manually.

> [!NOTE]
> Manual setup does not install dependencies or Zsh plugins. This is why the recommended setup uses `bootstrap.sh`.

Manual installers can enable the personal Git identities with:

```bash
git config --file="$HOME/.gitconfig.local" --add include.path \
  "$HOME/.config/dotfiles/personal/git/gitconfig.personal"
```

The Vespere Theme source is under `~/.config/dotfiles/personal/mailspring/vespere-theme/` and can also be selected through Mailspring's **Edit → Install Theme…** menu.

## External dependencies


| Area | Tools |
| --- | --- |
| Arch desktop | Hyprland, Noctalia |
| Terminal | Kitty, FiraCode Nerd Font |
| Shell | Zsh, Oh My Zsh, Starship, `fzf`, `zoxide` |
| Editor | Neovim `v0.12.0+` |
| Git | lazygit, git-split-diffs |
| CLI | bat, lsd |
| AI tooling | OpenCode |
| Runtimes | NVM/Node.js, Bun, plus language-specific tools used by Neovim |
| Optional personal applications | Mailspring with the Vespere Theme |

The exact package names live in:

- `~/.config/dotfiles/packages/core-pacman.txt`
- `~/.config/dotfiles/packages/core-aur.txt`
- `~/.config/dotfiles/packages/personal-apps.txt`

`~/.config/dotfiles/` contains installer resources rather than runtime state. You are free to delete it after setup, but those files are tracked: deleting them will appear as deletions in `dotfiles status`, and they must be restored before rerunning the bootstrap.


## Daily usage

Use `dotfiles` anywhere you would normally use `git`:

```bash
dotfiles status
dotfiles add .config/kitty/kitty.conf
dotfiles commit -m "Update Kitty config"
dotfiles push
```

To begin tracking another config:

```bash
dotfiles add .config/some-tool/config.yml
dotfiles commit -m "Add some-tool config"
```

## Repository notes

- Only one bare repository should use all of `$HOME` as its work tree.
- Machine-specific or secret values belong in untracked local files, not in the shared configuration.
- The desktop layer intentionally relies on Noctalia instead of maintaining separate utilities for features it already provides.
- Credit to the [Hacker News post](https://news.ycombinator.com/item?id=11070797) that popularized the bare-repository dotfiles technique.
