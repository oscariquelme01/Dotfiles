return {
	"tadaa/vimade",
	opts = {
		recipe = { "minimalist", { animate = true } },
		fadelevel = 0.3,
    blockitemfilter = {
        bufname = { "FzfLua" },
        filetype = { "fzf", "terminal" }
    }
	},
	config = function()
		require("vimade").setup({})
	end,
}
