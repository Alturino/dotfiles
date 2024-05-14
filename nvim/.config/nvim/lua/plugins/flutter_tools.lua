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
      local configs = require "nvchad.configs.lspconfig"
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
          on_attach = configs.on_attach,
          capabilities = configs.capabilities,
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
        "<leader>fld",
        "<CMD>FlutterDevices<CR>",
        desc = "Flutter Devices",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        "<leader>fle",
        "<CMD>FlutterEmulators<CR>",
        desc = "Flutter Emulators",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        "<leader>flr",
        "<CMD>FlutterReload<CR>",
        desc = "Flutter Reload",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        "<leader>flR",
        "<CMD>FlutterRestart<CR>",
        desc = "Flutter Restart",
        noremap = true,
        nowait = true,
        silent = true,
      },
      {
        "<leader>flq",
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
