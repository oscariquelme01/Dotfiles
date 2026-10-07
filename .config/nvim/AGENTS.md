# AGENTS.md

## Repo shape
- This is a personal Neovim config, not an application repo; there are no project test/build scripts or CI configs.
- `init.lua` is the entrypoint. It bootstraps `lazy.nvim`, imports only `plugins.ui`, `plugins.editor`, and `plugins.navigation`, then loads `lua/config/*.lua`.
- `lua/plugins/languages/` exists but is currently not active because its import is commented out in `init.lua`; do not assume Mason/LSP server specs there are loaded until that import is enabled.
- `old-config/` is an archive of the previous config; use it only for reference, not as active runtime code.

## Validation
- This repo is named `nvim-config`, so `nvim -u init.lua` from the repo root is not a faithful load check: Neovim will not automatically add this directory as the config runtime path.
- For a real headless load check, run it as an installed config, e.g. symlink/copy this repo to an `nvim` config dir or use isolated XDG dirs with an `nvim` symlink to this repo, then run `nvim --headless +qa`.
- Loading the config may bootstrap/update plugins through `lazy.nvim`; isolate `XDG_DATA_HOME`/`XDG_STATE_HOME` if you do not want to mutate the user’s existing Neovim plugin state.

## Editing conventions
- Lua files use 2-space indentation in the active config.
- Plugin keymaps belong in the plugin spec that defines the plugin; general Neovim mappings live in `lua/config/mappings.lua`.
- Keep `lazy-lock.json` consistent when plugin versions change; do not hand-edit it unless deliberately updating pins.
