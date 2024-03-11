return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    cmd = { "Refactor" },
    keys = {
      {
        "<leader>if",
        function()
          require("refactoring").refactor "Inline Function"
        end,
        desc = "Extrack block to file",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        mode = { "n", "x" },
        "<leader>iv",
        function()
          require("refactoring").refactor "Inline Var"
        end,
        desc = "Extrack block to inline variable",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        mode = { "n", "x" },
        "<leader>rr",
        function()
          require("telescope").extensions.refactoring.refactors()
        end,
        desc = "Telescope Refactor Selection",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        mode = { "x" },
        "<leader>rv",
        function()
          require("refactoring").refactor "Extract Variable"
        end,
        desc = "Extract block to variable",
        noremap = true,
        nowait = true,
        silent = true,
      },
    },
    opts = {
      prompt_func_return_type = {
        go = true,
        java = true,
        cpp = true,
        c = true,
        typescript = true,
        python = true,
        lua = true,
      },
      prompt_func_param_type = {
        go = true,
        java = true,
        cpp = true,
        c = true,
        typescript = true,
        python = true,
        lua = true,
      },
      printf_statements = {},
      print_var_statements = {},
    },
    config = function(_, opts)
      require("refactoring").setup(opts)
    end,
  },
}
