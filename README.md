# Dotfiles

My personal dotfiles!! Featuring [the very beautiful vesper theme](https://github.com/vladzima/vesper-theme), a terminal and development environment optimized for this AI era we live in, plus an opinionated Arch Linux desktop built with [Hyprland](https://hyprland.org/) and [Noctalia](https://noctalia.dev/).

The repository is managed as a bare Git repository with `$HOME` as its work tree. Config files therefore live where the applications expect them. No dotfile manager and no symlink farm required.

## Setup overview

### Desktop

- [Hyprland](https://hyprland.org/) with a keyboard-first configuration
- [Noctalia](https://noctalia.dev/) for the bar and system UI: application launcher, notifications and DND, clipboard history, wallpaper management, screenshots, lock/logout controls, Polkit agent, and audio/network/Bluetooth/brightness controls
- Laptop-friendly behavior, including locking, idle handling, battery information, and brightness controls, plus an integrated Noctalia-native greeter that makes you forget you are using Arch BTW.

### Terminal and shell

- [Kitty](https://sw.kovidgoyal.net/kitty/) as the terminal emulator
- Kitty splits, tabs, project sessions, custom tab bar, and a Vesper-inspired theme
- Seamless navigation between Kitty panes and Neovim
- Neovim-powered Kitty scrollback through [`kitty-scrollback.nvim`](https://github.com/mikesmithgh/kitty-scrollback.nvim)
- Zsh, Oh My Zsh, Starship, `fzf`, and `zoxide`

### Development tools

- Neovim pinned to `v0.12.0`, organized into UI, navigation, editor, language, and integration modules
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
curl -fsSL https://raw.githubusercontent.com/oscariquelme01/Dotfiles/master/bootstrap.sh | bash
```

The bootstrap is responsible for repository setup and machine-specific configuration. It:

- clones the repository as a bare repo at `~/.dotfiles`
- backs up checkout conflicts under `~/.dotfiles-backup/`
- checks the tracked files out directly into `$HOME`
- configures the bare repository for a home-directory work tree
- writes machine-local paths that cannot be expressed portably in tracked config
- installs the external Zsh plugins used by `.zshrc`
- builds Neovim from the upstream `v0.12.0` tag
- installs all the dependencies (or at least it tries!). It assumes we are working on Arch Linux with `pacman` and installs `yay` when AUR packages are needed.
    - if the script fails to install dependencies, the user will be notified with a list of packages that are still needed by the system
- shows the complete list of personal applications and asks whether to install them
- optionally enables my personal and per-organization Git configuration

The core setup includes Hyprland, Noctalia, Kitty, Zsh, Neovim, OpenCode, Git tooling, and their supporting packages. The package manifests under `~/.config/dotfiles/packages/` list package-manager dependencies; Neovim is built separately from source.

#### Pinned Neovim

After installing the core and selected optional packages, bootstrap clones [upstream Neovim](https://github.com/neovim/neovim), checks out `v0.12.0`, and builds it in `Release` mode with bundled dependencies. This requires internet access for the source and dependency downloads. `base-devel`, `cmake`, and `ninja` are included in the core packages, alongside editor tools such as `tree-sitter-cli`, Node.js, and npm. Failed package installations are still reported in the summary.

The editor and its runtime are installed under `~/.local/opt/neovim/v0.12.0/`, with a symlink at `~/.local/bin/nvim`. The Zsh configuration puts that directory first in `PATH`, so the pinned build takes precedence over a system Neovim. Start a new shell after installation.

Reruns reuse a completed installation with the expected version. Existing local launchers are backed up before replacement, temporary build files are cleaned up, and build/install failures appear in the bootstrap summary. Change `NVIM_TAG` in `bootstrap.sh` to deliberately select another release.

The Neovim config and `lazy-lock.json` are tracked under `~/.config/nvim/`. Run `:Lazy restore` inside Neovim to restore the plugin revisions recorded in the lockfile.

Mason installs the configured language servers, linters, and formatters, including `prettierd`. System packages supply their runtimes and other editor features: `fzf`/ripgrep/fd for search, `xdg-open` for Oil, TeX Live/latexmk and Zathura for LaTeX, and `latex2text` for Markdown math. VimTeX uses `zathura_simple` for viewing without xdotool. Rust formatting is configured but requires a separately installed `rustfmt`; Mason no longer distributes it.

#### Optional personal setup

This is a personal repository, but most of the setup is reusable. The bootstrap therefore keeps the opinionated extras behind separate prompts. It currently offers:

- **Personal applications:** Mailspring with the **Vesper Theme**
- **Personal Git configuration:** my default identity and conditional identities for organization directories

Mailspring and its theme are one choice, not separate installations. Vesper is my fork of the [Sparky Mailspring Theme](https://github.com/siniux/Sparky-Mailspring-Theme)

Bootstrap first asks whether to fetch [personal-dotfiles](https://github.com/oscariquelme01/personal-dotfiles). If accepted, it clones into `~/.local/share/personal-dotfiles/`. That is the fixed location for the personal checkout. Reruns use that checkout without pulling, resetting, or changing local edits; pull updates yourself when desired. Bootstrap shows the application list from `packages.txt` and asks separately about applications and Git identities. Declining the initial prompt skips the personal repository entirely.

Personal Git files are symlinked at `~/.config/git/personal/` and enabled through the untracked `~/.gitconfig.local`. A fresh checkout preserves the existing default Git name/email there; selecting personal Git settings overrides those defaults through the personal include. Organization includes use paths relative to the configuration. Mailspring's `packages/mailspring-theme-vesper` directory is also symlinked to the checkout. Existing destination directories are backed up under `~/.dotfiles-backup/` before replacement; correct links are reused on reruns.

Edits through either the application path or the checkout modify the same files and appear in the personal repository's `git status`. Keep `~/.local/share/personal-dotfiles/` in place: it is live configuration, unlike the removable installer resources under `~/.config/dotfiles/`.

The script asks again on every run; it does not maintain a separate selections file. Declining an option does not uninstall something selected during an earlier run. Failures are listed in the summary and produce a nonzero exit status.

## External dependencies


| Area | Tools |
| --- | --- |
| Arch desktop | Hyprland, Noctalia |
| Terminal | Kitty, FiraCode Nerd Font |
| Shell | Zsh, Oh My Zsh, Starship, `fzf`, `zoxide` |
| Editor | Neovim `v0.12.0` (built from source) |
| Documents | TeX Live, latexmk, Zathura with MuPDF support, python-pylatexenc |
| Git | lazygit, git-split-diffs |
| CLI | bat, lsd |
| AI tooling | OpenCode |
| Runtimes | NVM/Node.js, Bun, plus language-specific tools used by Neovim |
| Optional personal applications | Mailspring with the Vesper Theme |

The exact package names live in:

- `~/.config/dotfiles/packages/core-pacman.txt`
- `~/.config/dotfiles/packages/core-aur.txt`
- `packages.txt` in the optional personal-dotfiles repository

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
