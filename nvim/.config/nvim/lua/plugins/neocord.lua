return {
  {
    "IogaMaster/neocord",
    event = "BufEnter *",
    opts = {},
    config = function(_, opts)
      require("neocord").setup(opts)
    end,
  },
}
