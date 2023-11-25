return {
  {
    "max397574/better-escape.nvim",
    event = "BufEnter",
    opts = {
      mapping = { "jk", "jj", "kj", "kk" },
      timeout = 150,
      clear_empty_lines = false,
      keys = "<ESC>",
    },
    config = function(_, opts)
      require("better_escape").setup(opts)
    end,
  },
}
