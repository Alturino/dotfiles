return {
  {
    "max397574/better-escape.nvim",
    event = "BufEnter",
    opts = {
      mapping = { "jk", "jj", "kj", "kk" },
      timeout = vim.o.timeoutlen,
      clear_empty_lines = false,
      keys = function()
        return vim.api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>"
      end,
    },
    config = function(_, opts)
      require("better_escape").setup(opts)
    end,
  },
}
