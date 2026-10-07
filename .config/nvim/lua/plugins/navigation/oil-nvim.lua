return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = {
		{ "nvim-mini/mini.icons", opts = {} }
	},
  keys = {
    {
      "<leader>o",
      function()
        require("oil").open()
      end,
      desc = "Open directory (Oil)",
    },
  },

  opts = {
    default_file_explorer = true,
    columns = { "icon" },

    view_options = {
      show_hidden = true,
    },

    win_options = {
      winbar = "%!v:lua.require('oil').get_current_dir()",
    },

    use_default_keymaps = false,
    keymaps = {
      ["g?"] = { "actions.show_help", mode = "n" },
      ["<CR>"] = "actions.select",

      ["<C-s>"] = {
        "actions.select",
        opts = { vertical = true, close = true },
      },
      ["<C-x>"] = {
        "actions.select",
        opts = { horizontal = true, close = true },
      },
      ["<C-t>"] = {
        "actions.select",
        opts = { tab = true, close = true },
      },
      ["<C-r>"] = "actions.refresh",

      ["-"] = { "actions.parent", mode = "n" },
      ["_"] = { "actions.open_cwd", mode = "n" },
      ["`"] = { "actions.cd", mode = "n" },
      ["g~"] = {
        "actions.cd",
        opts = { scope = "tab" },
        mode = "n",
      },

      ["gs"] = { "actions.change_sort", mode = "n" },
      ["gx"] = "actions.open_external",
      ["g."] = { "actions.toggle_hidden", mode = "n" },
      ["g\\"] = { "actions.toggle_trash", mode = "n" },
      ["q"] = { "actions.close", mode = "n" },

      -- Ctrl-V remains native visual-block selection.
    },
  },
}
