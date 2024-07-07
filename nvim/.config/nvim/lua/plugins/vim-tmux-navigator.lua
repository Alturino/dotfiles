return {
  {
    "christoomey/vim-tmux-navigator",
    keys = {
      { "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", desc = "Tmux Navigate Left", mode = { "n", "x", "o", "v" } },
      { "<C-l>", "<Cmd>TmuxNavigateRight<CR>", desc = "Tmux Navigate Right", mode = { "n", "x", "o", "v" } },
      { "<C-j>", "<Cmd>TmuxNavigateDown<CR>", desc = "Tmux Navigate Down", mode = { "n", "x", "o", "v" } },
      { "<C-k>", "<Cmd>TmuxNavigateUp<CR>", desc = "Tmux Navigate Up", mode = { "n", "x", "o", "v" } },
    },
    lazy = false,
  },
}
