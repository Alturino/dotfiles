return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java", "*.properties", "*.gradle" },
    event = "BufEnter *.java",
    config = function()
      local vim = vim
      vim.keymap.set("n", "<leader>jc", "<cmd>JdtCompile<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>jsr", "<cmd>JdtSetRuntime<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>juc", "<cmd>JdtUpdateConfig<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>jud", "<cmd>JdtUpdateDebugConfig<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>juh", "<cmd>JdtUpdateHotCode<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>jb", "<cmd>JdtBytecode<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>jr", "<cmd>JdtRestart<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>oi", function()
        return require("jdtls").organize_imports()
      end, {
        noremap = true,
        silent = true,
      })

      vim.keymap.set({ "n", "v" }, "<leader>ev", function()
        return require("jdtls").extract_variable()
      end, {
        noremap = true,
        silent = true,
      })

      vim.keymap.set({ "n", "v" }, "<leader>ec", function()
        return require("jdtls").extract_constant()
      end, {
        noremap = true,
        silent = true,
      })

      vim.keymap.set("v", "<leader>em", function()
        return require("jdtls").extract_method(true)
      end, {
        noremap = true,
        silent = true,
      })

      vim.keymap.set("n", "<leader>df", function()
        return require("jdtls").test_class()
      end, {
        noremap = true,
        silent = true,
      })

      vim.keymap.set("n", "<leader>dn", function()
        return require("jdtls").test_nearest_method()
      end, {
        noremap = true,
        silent = true,
      })
    end,
    cmd = {
      "JdtCompile",
      "JdtSetRuntime",
      "JdtUpdateConfig",
      "JdtUpdateDebugConfig",
      "JdtUpdateHotCode",
      "JdtBytecode",
      "JdtJol",
      "JdtJshell",
      "JdtRestart",
    },
  },
}
