return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = {
      automatic_installation = true,
      automatic_setup = true,
      ensure_installed = {
        "cppdbg",
        "delve",
        "debugpy",
        "javadbg",
        "javatest",
        "kotlin",
        "bash",
        "js",
        "python",
        "dart",
        "delve",
        "firefox",
      },
    },
    config = function(_, opts)
      require("mason-nvim-dap").setup(opts)
    end,
  },
}
