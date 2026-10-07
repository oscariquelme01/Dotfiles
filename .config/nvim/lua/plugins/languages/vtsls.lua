return {
  {
    "yioneko/nvim-vtsls",
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserVtslsMappings", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or client.name ~= "vtsls" then
            return
          end

          local commands = require("vtsls").commands
          local opts = function(desc)
            return { buffer = ev.buf, silent = true, desc = desc }
          end

          vim.keymap.set("n", "<leader>gD", function()
            commands.goto_source_definition(0)
          end, opts("Go to source definition"))

          vim.keymap.set("n", "<leader>ti", function()
            commands.organize_imports(ev.buf)
          end, opts("Organize imports"))

          vim.keymap.set("n", "<leader>tu", function()
            commands.remove_unused_imports(ev.buf)
          end, opts("Remove unused imports"))

          vim.keymap.set("n", "<leader>ta", function()
            commands.add_missing_imports(ev.buf)
          end, opts("Add missing imports"))
        end,
      })
    end,
  },
}
