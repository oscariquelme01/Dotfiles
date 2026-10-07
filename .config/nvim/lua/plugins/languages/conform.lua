return {
	"stevearc/conform.nvim",
	cmd = { "ConformInfo", "Format" },
	event = "BufWritePre",

	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_organize_imports", "ruff_format" },

				-- Web / frontend
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				vue = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				jsonc = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },

				-- Scripting / documents / data
				bash = { "shfmt" },
				sh = { "shfmt" },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				mdx = { "prettierd", "prettier", stop_after_first = true },
				sql = { "sqlfluff" },
				tex = { "tex-fmt" },
				plaintex = { "tex-fmt" },

				-- Systems languages
				rust = { "rustfmt", lsp_format = "fallback" },
				c = { "clang-format" },
				cpp = { "clang-format" },
			},

			-- Do we want formatting on save tho?
			-- format_on_save = {
			-- 	timeout_ms = 1000,
			-- 	lsp_format = "fallback",
			-- },
		})

		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		vim.api.nvim_create_user_command("Format", function()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end, { desc = "Format buffer" })
	end,
}
