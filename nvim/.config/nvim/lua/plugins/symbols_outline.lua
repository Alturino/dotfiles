return {
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    opts = {},
    config = function(_, opts)
      require("symbols-outline").setup(opts)
    end,
  },
}
