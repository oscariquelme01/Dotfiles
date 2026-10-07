-- This file is meant to keep the keymaps for a better default neovim experience, each plugin's mappings should be set in its corresponding file
local keymap = vim.keymap.set

------- VISUAL MODE -------
-- move lines
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", {noremap = true, silent = true, desc = "move line up"})
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", {noremap = true, silent = true, desc = "move line down"})
-- indent
keymap("v", ">", ">gv", {noremap = true, silent = true, desc = "visual indent"})
keymap("v", "<", "<gv", {noremap = true, silent = true, desc = "visual indent"})

------- INSERT MODE -------
-- move lines
keymap("i", "<A-j>", "<ESC>:m .+1<CR>==gi", {noremap = true, silent = true, desc = "move line down"})
keymap("i", "<A-k>", "<ESC>:m .-2<CR>==gi", {noremap = true, silent = true, desc = "move line up"})
-- motions
keymap("i", "<C-h>", "<Left>", {desc = "move left"})
keymap("i", "<C-l>", "<Right>", {desc = "move right"})
keymap("i", "<C-j>", "<Down>", {desc = "move down"})
keymap("i", "<C-k>", "<Up>", {desc = "move up"})

------- NORMAL MODE -------
-- Resize panes
keymap("n", "<A-Left>", ":vertical resize +3<CR>", {noremap = true, silent = true, desc = "Resize window left"})
keymap("n", "<A-Right>", ":vertical resize -3<CR>", {noremap = true, silent = true, desc = "Resize window right"})
keymap("n", "<A-Up>", ":resize +3<CR>", {noremap = true, silent = true, desc = "Resize window up"})
keymap("n", "<A-Down>", ":resize +3<CR>", {noremap = true, silent = true, desc = "Resize window down"})
-- Move lines
keymap("n", "<A-j>", ":m .+1<CR>==", {noremap = true, silent = true, desc = "move line down"})
keymap("n", "<A-k>", ":m .-2<CR>==", {noremap = true, silent = true, desc = "move line up"})
-- Folds
keymap("n", "mm", ":foldopen<CR>", {noremap = true, silent = true, desc = "open fold"})
keymap("n", "mn", ":foldclose<CR>", {noremap = true, silent = true, desc = "close fold"})
-- Diagnostics
keymap("n", "<leader>de", vim.diagnostic.open_float, { desc = "Open diagnostic in float" })
keymap("n", "<leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
keymap("n", "<leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
keymap("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Set diagnostic location list" })
keymap("n", "<leader>dv", function() vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines }) end, { desc = "Toggle diagnostic virtual lines" })
-- Tab navigation
keymap('n', 'tn', ':tabnext<CR>', { silent = true, desc = 'Go to next tab'})
keymap('n', 'tp', ':tabprevious<CR>', { silent = true, desc = 'Go to previous tab'})
keymap('n', 'tc', ':tabclose<CR>', { silent = true, desc = 'Close tab'})
-- Remap for dealing with word wrap
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- Buffer navigation
keymap('n', '<TAB>', ':bn<CR>', { silent = true, desc = 'go to next buffer'})
keymap('n', '<S-TAB>', ':bp<CR>', { silent = true, desc = 'go to previous buffer'})
keymap('n', '<leader>x', ':bd<CR>', { silent = true, desc = 'delete buffer'})


------- LSP -------
-- Disable default LSP mappings before defining the preferred buffer-local ones.
for _, bind in ipairs({ "grn", "gri", "grr", "grt", "grx" }) do
  pcall(vim.keymap.del, "n", bind)
end
pcall(vim.keymap.del, "n", "gra")
pcall(vim.keymap.del, "x", "gra")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspMappings", { clear = true }),
  callback = function(ev)
    local bufnr = ev.buf
    local lsp = vim.lsp

    local function opt(desc)
      return { buffer = bufnr, silent = true, desc = desc }
    end

    keymap("n", "gd", lsp.buf.definition, opt("Go to definition"))
    keymap("n", "gi", lsp.buf.implementation, opt("Go to implementation"))
    keymap("n", "gr", lsp.buf.references, opt("Show references"))
    keymap("n", "K", function()
      lsp.buf.hover({ border = "single", max_height = 30, max_width = 120 })
    end, opt("Hover documentation"))
    keymap("n", "<leader>ra", lsp.buf.rename, opt("Rename symbol"))
    keymap({ "n", "v" }, "<leader>ca", lsp.buf.code_action, opt("Code action"))
    keymap("n", "<leader>dD", lsp.buf.workspace_diagnostics, opt("Populate workspace diagnostics"))
  end,
})
