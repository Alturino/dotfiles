return {
  {
    "rmagatti/goto-preview",
    opts = {},
    config = function(_, opts)
      require("goto-preview").setup(opts)
    end,
  },
}
