return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "InsertLeave" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				-- Web / frontend
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				vue = { "eslint_d" },
				css = { "stylelint" },
				html = { "htmlhint" },

				-- Scripting / backend
				python = { "ruff" },
				bash = { "shellcheck" },
				sh = { "shellcheck" },

				-- Documents / data
				markdown = { "markdownlint-cli2" },
				mdx = { "markdownlint-cli2" },
				sql = { "sqlfluff" },
			}

			vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("UserLint", { clear = true }),
				callback = function()
					lint.try_lint()
				end,
			})

			vim.schedule(function()
				lint.try_lint()
			end)
		end,
	},
}
