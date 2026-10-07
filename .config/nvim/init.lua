-- Set <space> as the leader key
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local opts = {}
require("lazy").setup({
	{ import = "plugins.ui" },
	{ import = "plugins.editor" },
	{ import = "plugins.navigation" },
	{ import = "plugins.languages" },
	-- Integrations = things I use outside neovim that make sense to interact with while inside neovim
	{ import = "plugins.integrations.git" },
	{ import = "plugins.integrations.opencode" },
	{ import = "plugins.integrations.kitty" },
	{ import = "plugins.integrations.databases" }
}, opts)

require("config.mappings")
require("config.options")
require("config.lsp")
require("config.filetypes")
require("config.statusline")
