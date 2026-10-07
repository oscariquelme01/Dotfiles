return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		opts = {
			ensure_installed = {
				-- Formatters
				"clang-format",
				"prettierd",
				"shfmt",
				"stylua",
				"tex-fmt",

				-- Linters
				"eslint_d",
				"htmlhint",
				"markdownlint-cli2",
				"ruff",
				"shellcheck",
				"sqlfluff",
				"stylelint",

				-- TODO: curate this list!
			},
		},
	},
}
