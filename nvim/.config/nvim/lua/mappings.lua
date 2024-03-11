require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- General
map("n", "<C-Down>", "<C-w>-", { desc = "Decrease buffer height", silent = true, noremap = true })
map("n", "<C-Left>", "<C-w><", { desc = "Decrease buffer width", silent = true, noremap = true })
map("n", "<C-Right>", "<C-w>>", { desc = "Increase buffer width", silent = true, noremap = true })
map("n", "<C-Up>", "<C-w>+", { desc = "Increase buffer height", silent = true, noremap = true })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and focus center", silent = true, noremap = true })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and focus center", silent = true, noremap = true })
map("n", "<leader>dba", "<CMD>DBUIAddConnection<CR>",
  { desc = "Dadbod ui add connection", silent = true, noremap = true })
map("n", "<leader>dbt", "<CMD>DBUIToggle<CR>", { desc = "Dadbod ui toggle", silent = true, noremap = true })
map("n", "<leader>fm", function() vim.lsp.buf.format { async = true } end,
  { desc = "LSP formatting", silent = true, noremap = true })
map("n", "<leader>hs", "<CMD>split<CR><C-j>", { desc = "Horizontal Split", silent = true, noremap = true })
map("n", "<leader>tct", "<CMD>TSContextToggle<CR>", { desc = "Treesitter context toggle", silent = true, noremap = true })
map("n", "<leader>vs", "<CMD>vsplit<CR><C-l>", { desc = "Vertical Split", silent = true, noremap = true })
map("n", "<leader>xa", function() require("nvchad.tabufline").closeOtherBufs() end,
  { desc = "Close buffers except current buffer", silent = true, noremap = true })

-- Harpoon
map("n", "<leader>h1", function()
  local harpoon = require "harpoon"
  harpoon:list():select(1)
end, { desc = "Harpoon 1", silent = true, noremap = true })
map("n", "<leader>h2", function()
  local harpoon = require "harpoon"
  harpoon:list():select(2)
end, { desc = "Harpoon 2", silent = true, noremap = true })
map("n", "<leader>h3", function()
  local harpoon = require "harpoon"
  harpoon:list():select(3)
end, { desc = "Harpoon 3", silent = true, noremap = true })
map("n", "<leader>h4", function()
  local harpoon = require "harpoon"
  harpoon:list():select(4)
end, { desc = "Harpoon 4", silent = true, noremap = true })
map("n", "<leader>hls", function()
  local harpoon = require "harpoon"
  harpoon.logger:show()
end, { desc = "Harpoon logger show", silent = true, noremap = true })
map("n", "<leader>ha", function()
  local harpoon = require "harpoon"
  harpoon:list():append()
end, { desc = "Harpoon Add", silent = true, noremap = true })
map("n", "<leader>hm", function()
  local harpoon = require "harpoon"
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon Menu", silent = true, noremap = true })

-- Git Signs
map({ "n", "x", "o", "v", "i" }, "[h",
  function()
    local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
    local gs = require "gitsigns"
    local _, prev_hunk = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
    return prev_hunk()
  end, { desc = "Goto previous hunk", silent = true, noremap = true })
map({ "n", "x", "o", "v", "i" }, "]h",
  function()
    local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
    local gs = require "gitsigns"
    local _, prev_hunk = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
    return prev_hunk()
  end, { desc = "Goto next hunk", silent = true, noremap = true })

-- Tmux
map({ "n", "x", "o", "v", "i" }, "<C-h>", "<Cmd>TmuxNavigateLeft<CR>",
  { desc = "Navigate tmux window left", silent = true, noremap = true })
map({ "n", "x", "o", "v", "i" }, "<C-j>", "<Cmd>TmuxNavigateDown<CR>",
  { desc = "Navigate tmux window down", silent = true, noremap = true })
map({ "n", "x", "o", "v", "i" }, "<C-k>", "<Cmd>TmuxNavigateUp<CR>",
  { desc = "Navigate tmux window up", silent = true, noremap = true })
map({ "n", "x", "o", "v", "i" }, "<C-l>", "<Cmd>TmuxNavigateRight<CR>",
  { desc = "Navigate tmux window right", silent = true, noremap = true })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files no_ignore=false hidden=true<cr>",
  { desc = "Find files", silent = true, noremap = true })
map("n", "<leader>fgb", function() require("telescope.builtin").git_branches() end,
  { desc = "Find git branches", silent = true, noremap = true })
map("n", "<leader>fgc", function() require("telescope.builtin").git_commits() end,
  { desc = "Find git commits", silent = true, noremap = true })
map("n", "<leader>fgs", function() require("telescope.builtin").git_status() end,
  { desc = "Find git status", silent = true, noremap = true })
map("n", "<leader>fgsh", function() require("telescope.builtin").git_stash() end,
  { desc = "Find git stash", silent = true, noremap = true })
map("n", "<leader>fh", "<cmd>Telescope harpoon marks<cr>", { desc = "Find Harpoon", silent = true, noremap = true })
map("n", "<leader>fic", function() require("telescope.builtin").lsp_incoming_calls() end,
  { desc = "Find lsp incoming call", silent = true, noremap = true })
map("n", "<leader>foc", function() require("telescope.builtin").lsp_outgoing_calls() end,
  { desc = "Find lsp outgoing call", silent = true, noremap = true })
map("n", "<leader>fs", function() require("telescope.builtin").lsp_workspace_symbols() end,
  { desc = "Find symbols", silent = true, noremap = true })
map("n", "<leader>fu", function() require("telescope.builtin").lsp_references() end,
  { desc = "Find Usages", silent = true, noremap = true })

-- LSP
map("n", "<leader>cA", function() vim.lsp.buf.code_action { context = { only = { "source", }, diagnostics = {}, }, } end,
  { desc = "Goto previous error", silent = true, noremap = true })
map("n", "<leader>tf", function() vim.lsp.buf.type_definition() end,
  { desc = "Type definition", silent = true, noremap = true })
map("n", "[e",
  function()
    local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
    local v = vim
    local n = function() return v.diagnostic.goto_next { severity = v.diagnostic.severity.ERROR, float = { border = "rounded" }, } end
    local p = function() v.diagnostic.goto_prev { severity = v.diagnostic.severity.ERROR, float = { border = "rounded" }, } end
    local _, prev = ts_move.make_repeatable_move_pair(n, p)
    return prev()
  end, { desc = "Goto previous error", silent = true, noremap = true })
map("n", "[w",
  function()
    local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
    local v = vim
    local n = function() return v.diagnostic.goto_next { severity = v.diagnostic.severity.WARN, float = { border = "rounded" }, } end
    local p = function() v.diagnostic.goto_prev { severity = v.diagnostic.severity.WARN, float = { border = "rounded" }, } end
    local _, prev = ts_move.make_repeatable_move_pair(n, p)
    return prev()
  end, { desc = "Goto previous warning", silent = true, noremap = true })
map("n", "]e",
  function()
    local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
    local v = vim
    local n = function() return v.diagnostic.goto_next { severity = v.diagnostic.severity.ERROR, float = { border = "rounded" }, } end
    local p = function() v.diagnostic.goto_prev { severity = v.diagnostic.severity.ERROR, float = { border = "rounded" }, } end
    local next, _ = ts_move.make_repeatable_move_pair(n, p)
    return next()
  end, { desc = "Goto next error", silent = true, noremap = true })
map("n", "]w",
  function()
    local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
    local v = vim
    local n = function() return v.diagnostic.goto_next { severity = v.diagnostic.severity.WARN, float = { border = "rounded" }, } end
    local p = function() v.diagnostic.goto_prev { severity = v.diagnostic.severity.WARN, float = { border = "rounded" }, } end
    local next, _ = ts_move.make_repeatable_move_pair(n, p)
    return next()
  end, { desc = "Goto next warning", silent = true, noremap = true })

-- Trouble
map("n", "<leader>qf", "<Cmd>TroubleToggle quickfix<CR>",
  { desc = "TroubleToggle quick fix", silent = true, noremap = true })
map("n", "<leader>tt", "<Cmd>TroubleToggle<CR>", { desc = "Trouble toggle", silent = true, noremap = true })
map("n", "<leader>wd", "<Cmd>TroubleToggle workspace_diagnostics<CR>",
  { desc = "TroubleToggle workspace diagnostics", silent = true, noremap = true })

-- Treesitter Textobjects
map({ "n", "x", "o" }, ",",
  function()
    local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
    return ts_repeat_move.repeat_last_move_opposite()
  end, { desc = "Treesitter Repeat Last Move Previous", silent = true, noremap = true })
map({ "n", "x", "o" }, ";",
  function()
    local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
    return ts_repeat_move.repeat_last_move()
  end, { desc = "Treesitter Repeat Last Move Next", silent = true, noremap = true })
map({ "n", "x", "o" }, "F",
  function()
    local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
    return ts_repeat_move.builtin_F()
  end, { desc = "Treesitter Repeat Builtin F", silent = true, noremap = true })
map({ "n", "x", "o" }, "T",
  function()
    local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
    return ts_repeat_move.builtin_T()
  end, { desc = "Treesitter Repeat Builtin T", silent = true, noremap = true })
map({ "n", "x", "o" }, "f",
  function()
    local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
    return ts_repeat_move.builtin_f()
  end, { desc = "Treesitter Repeat Builtin f", silent = true, noremap = true })
map({ "n", "x", "o" }, "t",
  function()
    local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
    return ts_repeat_move.builtin_t()
  end, { desc = "Treesitter Repeat Builtin t", silent = true, noremap = true })

map("i", "jk", "<ESC>", { desc = "ESC", silent = true, noremap = true })
