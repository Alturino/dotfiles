return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = { automatic_installation = false },
    cmd = { "LspInstall", "LspUninstall" },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
    dependencies = { "mason-org/mason.nvim" },
  },
}
