return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "BufReadPre",
  opts = {
    query = {
      [""] = "rainbow-delimiters",
      lua = "rainbow-blocks",
    },
    priority = {
      [""] = 110,
      lua = 210,
    },
    highlight = {
      "RainbowDelimiterRed",
      "RainbowDelimiterYellow",
      "RainbowDelimiterBlue",
      "RainbowDelimiterOrange",
      "RainbowDelimiterGreen",
      "RainbowDelimiterViolet",
      "RainbowDelimiterCyan",
    },
  },
  config = function(_, opts)
    local rainbow_delimiters = require "rainbow-delimiters.setup"
    dofile(vim.g.base46_cache .. "rainbowdelimiters")
    rainbow_delimiters.setup {
      query = opts.query,
      highlight = opts.highlight,
    }
  end,
}
