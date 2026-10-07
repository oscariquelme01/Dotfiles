return {
  "kevinhwang91/nvim-ufo",
  dependencies = "kevinhwang91/promise-async",
  event = "BufReadPost",

  init = function()
    vim.o.foldcolumn = "0"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,

  opts = {
    provider_selector = function()
      return { "treesitter", "indent" }
    end,

    preview = {
      win_config = {
        border = "single",
        winblend = 0,
      },
    },
  },

  keys = {
    {
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
      desc = "Open all folds",
    },
    {
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
      desc = "Close all folds",
    },
    {
      "K",
      function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()

        if not winid then
          vim.lsp.buf.hover()
        end
      end,
      desc = "Peek fold or hover",
    },
  },
}
