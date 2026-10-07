return {
	"datsfilipe/vesper.nvim",
	config = function()
		require("vesper").setup({
			transparent = false, -- Boolean: Sets the background to transparent
			italics = {
				comments = true, -- Boolean: Italicizes comments
				keywords = true, -- Boolean: Italicizes keywords
				functions = false, -- Boolean: Italicizes functions
				strings = true, -- Boolean: Italicizes strings
				variables = false, -- Boolean: Italicizes variables
			},
			overrides = {}, -- A dictionary of group names, can be a function returning a dictionary or a table.
			palette_overrides = {},
		})

		vim.cmd.colorscheme("vesper")

		-- Syntax highlights for the tabline
		vim.api.nvim_set_hl(0, "TabLineFill", {
			bg = "#101010",
		})

		vim.api.nvim_set_hl(0, "TabLine", {
			fg = "#707070",
			bg = "#101010",
		})

		vim.api.nvim_set_hl(0, "TabLineSel", {
			fg = "#FFC799",
			bg = "#101010",
			bold = true,
		})

		-- fzf.lua background
		vim.api.nvim_set_hl(0, "PMenuSBar", { bg = "#101010" })

		-- blink.indent colors
		vim.api.nvim_set_hl(0, "BlinkIndent", { fg = '#405A50' })
		vim.api.nvim_set_hl(0, "BlinkIndentScope", { fg = '#A89870' })
	end,
}
