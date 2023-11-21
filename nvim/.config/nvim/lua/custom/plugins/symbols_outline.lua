return {
  {
    "simrat39/symbols-outline.nvim",
    keys = { { "<leader>tso", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    cmd = "SymbolsOutline",
    opts = {},
    config = function(_, opts)
      require("symbols-outline").setup(opts)
    end,
  },
}
