return {
  {
    "stevearc/oil.nvim",
    cmd = { "Oil" },
    event = "VeryLazy",
    keys = {
      -- stylua: ignore start
      { "<leader>e", "<cmd>Oil<cr>",                               desc = "Oil toggle",       nowait = true, noremap = true },
      { "<leader>E", function() require("oil").toggle_float() end, desc = "Oil toggle float", nowait = true, silent = true, noremap = true },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      columns = {
        "icon",
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
  },
}
