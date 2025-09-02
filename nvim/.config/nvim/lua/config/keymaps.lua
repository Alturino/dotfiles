-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local set = vim.keymap.set
local del = vim.keymap.del

del("n", "<leader>cf")

-- stylua: ignore start
set("i", "jk", "<ESC>", { desc = "ESC", silent = true, noremap = true })
set("i", "jj", "<ESC>", { desc = "ESC", silent = true, noremap = true })

set("n", "<leader>fm", function() vim.lsp.buf.format { async = false } end, { desc = "LSP formatting", silent = true, noremap = true, nowait = true })
set("x", "<leader>fm", function() vim.lsp.buf.format { async = false } end, { desc = "LSP formatting", silent = true, noremap = true, nowait = true })

set("n", "<leader>hs", "<CMD>split<CR><C-j>", { desc = "Horizontal Split", silent = true, noremap = true })
set("n", "<leader>vs", "<CMD>vsplit<CR><C-l>", { desc = "Vertical Split", silent = true, noremap = true })
set("n", "[b", "<C-O>", { desc = "Jump Back", silent = true, noremap = true })
set("n", "]b", "<C-I>", { desc = "Jump Forward", silent = true, noremap = true })

set("n", "<C-Up>", "<C-w>+", { desc = "Increase buffer height", silent = true, noremap = true })
set("n", "<C-d>", "<C-d>zz", { desc = "Scroll half down and focus center", silent = true, noremap = true })
set("n", "<C-u>", "<C-u>zz", { desc = "Scroll half up and focus center", silent = true, noremap = true })
set("n", "<leader>q", "<CMD>q<CR>", { desc = "Quit from buffer", silent = true, noremap = true })
set("n", "<leader>qa", "<CMD>qa<CR>", { desc = "Quit all", silent = true, noremap = true })

set("n", "<leader>rA", Snacks.rename.rename_file, { desc = "Rename File" })
set("n", "<leader>ra", vim.lsp.buf.rename, { desc = "Rename" })

set("n", "<leader>cA", function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end, { desc = "code action", silent = true, noremap = true })
set("n", "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation", silent = true, noremap = true })
set("x", "p", "\"_dP", { desc = "Paste without copying to register", silent = true, noremap = true })
