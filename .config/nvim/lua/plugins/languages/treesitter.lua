return {
  -- Parsers, highlighting, and indentation
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',

    config = function()
      require('nvim-treesitter').install({
				-- Neovim
				'lua',
				'vim',
				'vimdoc',
				'query',

				-- Web development
				'javascript', -- Includes JSX
				'typescript',
				'tsx',
				'vue',
				'html',
				'css',
				'json',
				'yaml',

				-- Other languages and documents
				'python',
				'sql',
				'markdown',
				'markdown_inline',
				'bash',
				'latex',

				-- Systems languages
				'rust',
				'c',
				'cpp',
      })

			-- enable treesitter highlighting and identation
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('UserTreesitter', {
          clear = true,
        }),
        callback = function(args)
          -- VimTeX owns syntax highlighting and indentation for TeX buffers.
          -- Keep the LaTeX parser installed for injections such as Markdown math.
          if args.match == 'tex' or args.match == 'plaintex' then
            return
          end

          -- Skip buffers without an installed parser.
          local started = pcall(vim.treesitter.start, args.buf)
          if not started then
            return
          end

          vim.bo[args.buf].indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- Text objects & incremental selection
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },

    opts = {
      select = {
        lookahead = true,
      },
      move = {
        set_jumps = true,
      },
    },

    config = function(_, opts)
      require('nvim-treesitter-textobjects').setup(opts)

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')

      local objects = {
        aa = { '@parameter.outer', 'Around argument' },
        ia = { '@parameter.inner', 'Inside argument' },
        af = { '@function.outer', 'Around function' },
        ['if'] = { '@function.inner', 'Inside function' },
        ac = { '@class.outer', 'Around class' },
        ic = { '@class.inner', 'Inside class' },
      }

      for key, object in pairs(objects) do
        vim.keymap.set({ 'x', 'o' }, key, function()
          select.select_textobject(object[1], 'textobjects')
        end, { desc = object[2] })
      end

			local movements = {
				[']a'] = { 'goto_next_start', '@parameter.inner', 'Next parameter' },
				['[a'] = { 'goto_previous_start', '@parameter.inner', 'Previous parameter' },

				[']c'] = { 'goto_next_start', '@class.outer', 'Next class' },
				['[c'] = { 'goto_previous_start', '@class.outer', 'Previous class' },

				[']f'] = { 'goto_next_start', '@function.outer', 'Next function' },
				['[f'] = { 'goto_previous_start', '@function.outer', 'Previous function' },
			}

      for key, movement in pairs(movements) do
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          move[movement[1]](movement[2], 'textobjects')
        end, { desc = movement[3] })
      end
    end,
  },

  -- One-line sticky context
  {
    'nvim-treesitter/nvim-treesitter-context',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },

    opts = {
      max_lines = 1,
      multiline_threshold = 1,
    },

    keys = {
      {
        'gC',
        function()
          require('treesitter-context').go_to_context(vim.v.count1)
        end,
        desc = 'Go to enclosing context',
        silent = true,
      },
    },
  },
}
