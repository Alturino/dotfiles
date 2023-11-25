return {
  {
    "akinsho/flutter-tools.nvim",
    event = "BufEnter *.dart",
    dependencies = {
      "neovim/nvim-lspconfig",
      "dart-lang/dart-vim-plugin",
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = function()
      local on_attach = require("plugins.configs.lspconfig").on_attach
      local capabilities = require("plugins.configs.lspconfig").capabilities
      require("flutter-tools").setup {
        ui = {
          notification_style = "plugin",
        },
        decorations = {
          statusline = {
            app_version = true,
            device = true,
            project_config = true,
          },
        },
        dev_tools = {
          autostart = true,
          auto_open_browser = true,
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
        },
        lsp = {
          on_attach = on_attach,
          capabilities = capabilities,
          color = {
            enabled = true,
            background = true,
            virtual_text = true,
          },
        },
        widget_guides = {
          enabled = true,
        },
      }
      vim.keymap.set("n", "<leader>rn", "<CMD>FlutterRun<CR>", { noremap = true, nowait = true, silent = true })
    end,
    keys = {
      {
        "<leader>fd",
        "<CMD>FlutterDevices<CR>",
        desc = "Flutter Devices",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        "<leader>fe",
        "<CMD>FlutterEmulators<CR>",
        desc = "Flutter Emulators",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        "<leader>fr",
        "<CMD>FlutterReload<CR>",
        desc = "Flutter Reload",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        "<leader>fR",
        "<CMD>FlutterRestart<CR>",
        desc = "Flutter Restart",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        "<leader>fq",
        "<CMD>FlutterQuit<CR>",
        desc = "Flutter Quit",
        noremap = true,
        nowait = true,
        silent = true,
      },
    },
    cmd = {
      "FlutterRun",
      "FlutterDevices",
      "FlutterEmulators",
      "FlutterReload",
      "FlutterRestart",
      "FlutterQuit",
      "FlutterDetach",
      "FlutterOutlineToggle",
      "FlutterOutlineOpen",
      "FlutterDevTools",
      "FlutterDevToolsActivate",
      "FlutterCopyProfilerUrl",
      "FlutterLspRestart",
      "FlutterSuper",
      "FlutterReanalyze",
      "FlutterRename",
    },
  },
}
