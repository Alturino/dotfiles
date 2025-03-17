return {
  {
    "vyfor/cord.nvim",
    build = ":Cord update",
    event = "VeryLazy",
    opts = {
      log_level = vim.log.levels.OFF,
    },
    config = function(_, opts)
      require("cord").setup(opts)
    end,
  },
}
