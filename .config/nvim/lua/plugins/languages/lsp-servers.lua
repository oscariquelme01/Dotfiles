return {
  -- server config provider cause I don't wanna be searching for configs 24/7
  {
    "neovim/nvim-lspconfig",
  },
  -- bridge between mason & lspconfig: ensure_installed provider + removes the need to do 'vim.lsp.enable("<server-name>")'
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    opts = {
      automatic_enable = {
        -- Prefer vtsls for TypeScript/JavaScript and Vue integration in this config.
        -- Removing ts_ls from ensure_installed does not disable an already-installed
        -- server: exclude it explicitly to avoid two TypeScript clients attaching.
        exclude = { "ts_ls" },
      },
      ensure_installed = {
        -- Neovim / Lua
        "lua_ls",

        -- Web / frontend
        "vtsls",
        "vue_ls",
        "html",
        "cssls",
        "tailwindcss",

        -- Scripting / backend
        "pyright",
        "bashls",

        -- Documents / data
        "marksman",
        "sqlls",
        "texlab",

        -- Systems languages from the old config
        "clangd",

        -- Future systems-language options:
        -- "rust_analyzer",
        -- "gopls",
      },
    },
  },
}
