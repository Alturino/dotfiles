return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "nvimtools/none-ls.nvim",
        opts = function()
          return require "configs.null_ls"
        end,
        config = function(_, opts)
          require("null-ls").setup(opts)
        end,
      },
      { "b0o/schemastore.nvim" },
      { "nvim-java/nvim-java", ft = { "java" } },
    },
    config = function()
      require("java").setup()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
      vim.lsp.set_log_level "debug"
    end, -- Override to setup mason-lspconfig
  },
}
