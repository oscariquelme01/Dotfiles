local keymap = vim.api.nvim_set_keymap

return {
  "MunsMan/kitty-navigator.nvim",
  build = {
    "cp navigate_kitty.py ~/.config/kitty",
    "cp pass_keys.py ~/.config/kitty"
  },
  keys = {
   { "<C-h>", function() require("kitty-navigator").navigateLeft() end, desc = "Move left"},
   { "<C-j>", function() require("kitty-navigator").navigateDown() end, desc = "Move down"},
   { "<C-k>", function() require("kitty-navigator").navigateUp() end, desc = "Move up"},
   { "<C-l>", function() require("kitty-navigator").navigateRight() end, desc = "Move right"}
  }
}
