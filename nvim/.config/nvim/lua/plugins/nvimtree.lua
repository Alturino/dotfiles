return {
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      git = {
        enable = true,
      },

      filters = {
        custom = {
          "build",
          "dist",
          "lib",
          "node_modules",
        },
      },

      renderer = {
        highlight_git = true,
        icons = {
          show = {
            git = true,
          },
        },
      },

      view = {
        relativenumber = true,
        centralize_selection = true,
      },
    },
  }
}
