return {
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    config = function(_, opts)
      local debugpy_path = require("mason-registry").get_package("debugpy"):get_install_path()
      local debugpy_executable = function()
        if vim.fn.has "win32" == 1 then
          return debugpy_path .. "/venv/Scripts/python"
        end
        return debugpy_path .. "/venv/bin/python"
      end
      require("dap-python").setup(debugpy_executable())
    end,
  },
}
