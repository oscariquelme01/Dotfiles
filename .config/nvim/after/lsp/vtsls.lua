local mason_root = require("mason.settings").current.install_root_dir

-- Extend nvim-lspconfig's vtsls defaults with Vue hybrid-mode support.
return {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
  settings = {
    typescript = { updateImportsOnFileMove = { enabled = "always" } },
    javascript = { updateImportsOnFileMove = { enabled = "always" } },
    vtsls = {
      autoUseWorkspaceTsdk = true,
      enableMoveToFileCodeAction = true,
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = mason_root .. "/packages/vue-language-server/node_modules/@vue/language-server",
            languages = { "vue" },
            configNamespace = "typescript",
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
  },
}
