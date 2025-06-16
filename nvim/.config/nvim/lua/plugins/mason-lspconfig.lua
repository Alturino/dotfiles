return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = { automatic_installation = true },
    cmd = { "LspInstall", "LspUninstall" },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
    dependencies = { "williamboman/mason.nvim" },
  },
}
