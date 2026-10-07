return {
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  opts = {
    -- See `:help gitsigns.txt`
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
      vim.keymap.set('n', '<leader>gh', require('gitsigns').preview_hunk_inline, { buffer = bufnr, desc = 'Preview git hunk' })

      -- don't override the built-in and fugitive keymaps
      local gs = package.loaded.gitsigns
      vim.keymap.set({ 'n', 'v' }, '<leader>gn', function()
        vim.schedule(function()
          gs.nav_hunk("next")
        end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })

      vim.keymap.set({ 'n', 'v' }, '<leader>gp', function()
        vim.schedule(function()
          gs.nav_hunk("prev")
        end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
    end,
  },
}
