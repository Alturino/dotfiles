return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "blankline")
      require("ibl").setup(opts)
    end,
  },
}
