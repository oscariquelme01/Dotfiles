return {
  "kawre/leetcode.nvim",
  cmd = "Leet",
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lang = "typescript",
    picker = {
      provider = "fzf-lua",
    },
  },
}
