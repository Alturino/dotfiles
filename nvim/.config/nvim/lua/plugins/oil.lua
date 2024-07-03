return {
  {
    "stevearc/oil.nvim",
    opts = {
      columns = {
        "icon",
        "mtime",
      },
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          return name == ".git"
        end,
      },
      keymaps = {
        ["<C-s>"] = false,
        ["<C-h>"] = false,
        ["<leader>e"] = "actions.close",
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)
    end,
    cmd = { "Oil" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
