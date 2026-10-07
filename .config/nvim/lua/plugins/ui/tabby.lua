return {
  "nanozuki/tabby.nvim",
  lazy = false,
  init = function()
    vim.opt.showtabline = 1 -- Only show with two or more tabs
  end,
	keys = {
    {
      "tt",
      function()
        vim.ui.input({ prompt = "Tab name: " }, function(name)
          if name and name:match("%S") then
            vim.cmd("Tabby rename_tab " .. name)
          end
        end)
      end,
      desc = "Rename tab",
    },
  },
  opts = {
    line = function(line)
      return {
        line.tabs().foreach(function(tab)
          return {
						string.format(" %d  %s ", tab.number(), tab.name()),
            hl = tab.is_current() and "TabLineSel" or "TabLine",
          }
        end),
        line.spacer(),
        hl = "TabLineFill",
      }
    end,
  },
}
