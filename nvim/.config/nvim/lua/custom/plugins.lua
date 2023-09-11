local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
    build = ":MasonUpdate",
  },

  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPre",
    opts = overrides.treesitter,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    config = function()
      require("treesitter-context").setup {}
    end,
    event = "BufReadPre",
    cmd = { "TSContextEnable", "TSContextDisable", "TSContextToggle" },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    event = "BufReadPre",
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    cmd = "Telescope",
    opts = overrides.telescope,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    dependencies = "nvim-telescope/telescope.nvim",
  },

  {
    "NvChad/nvim-colorizer.lua",
  },

  {
    "mg979/vim-visual-multi",
  },

  -- Custom Plugins
  {
    "williamboman/mason-lspconfig.nvim",
    opts = overrides.mason_lspconfig,
    cmd = { "LspInstall", "LspUninstall" },
    dependencies = {
      { "williamboman/mason.nvim" },
      { "neovim/nvim-lspconfig" },
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup()
    end,
  },

  {
    "lervag/vimtex",
    event = "BufEnter *.tex",
    ft = { "tex" },
    cmd = {
      "VimtexInfo",
      "VimtexTocOpen",
      "VimtexTocToggle",
      "VimtexCompile",
      "VimtexStop",
      "VimtexClean",
    },
    config = function()
      require "custom.configs.vimtex"
    end,
  },

  {
    "fatih/vim-go",
    cmd = {
      "GoBuild",
      "GoInstall",
      "GoTest",
      "GoTestFunc",
      "GoRun",
      "GoDebugStart",
      "GoDef",
      "GoDoc",
      "GoRename",
      "GoLint",
      "GoMetaLinter",
      "GoErrCheck",
    },
    event = "BufEnter *.go",
    build = ":GoUpdateBinaries",
    enabled = true,
    ft = { "go", "gomod", "gosum" },
    keys = {
      { "<leader>rn", "<cmd>GoRun<cr>", desc = "Run go" },
    },
  },

  {
    "ThePrimeagen/vim-be-good",
    cmd = { "VimBeGood" },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        config = function()
          require("dapui").setup()
        end,
      },
      {
        "jay-babu/mason-nvim-dap.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        config = function()
          require("mason-nvim-dap").setup {
            automatic_setup = overrides.mason_dap.automatic_setup,
            ensure_installed = overrides.mason_dap.ensure_installed,
            automatic_installation = overrides.mason_dap.automatic_installation,
          }
        end,
      },
      {
        "leoluz/nvim-dap-go",
        opts = overrides.dap_go,
        config = function(_, opts)
          require("dap-go").setup(opts)
        end,
      },
    },
    config = function()
      require "custom.configs.nvim-dap"
    end,
  },

  {
    "folke/neodev.nvim",
    opts = {},
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require "notify"
      notify.setup {}
      vim.notify = notify
    end,
    lazy = false,
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleClose", "TroubleToggle", "TroubleRefresh" },
    opts = {},
  },

  {
    "preservim/vim-markdown",
    event = "BufEnter *.md",
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp-signature-help" },
    opts = overrides.cmp,
  },

  {
    "hrsh7th/cmp-cmdline",
    event = "InsertEnter",
    config = function(_, opts)
      require "custom.configs.cmp-cmdline"
    end,
  },

  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    cmd = { "Refactor" },
    config = function()
      local refactoring = require "refactoring"
      refactoring.setup {
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
      }
    end,
  },

  {
    "akinsho/flutter-tools.nvim",
    event = "BufEnter *.dart",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = function()
      require("flutter-tools").setup {}
    end,
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

  {
    "ellisonleao/glow.nvim",
    event = "BufEnter *.md",
    config = function()
      require("glow").setup {
        style = "dark",
        width = 120,
      }
    end,
    cmd = "Glow",
  },

  {
    "windwp/nvim-ts-autotag",
    ft = {
      "html",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
      "vue",
      "tsx",
      "jsx",
      "rescript",
      "xml",
      "php",
      "markdown",
      "astro",
      "glimmer",
      "handlebars",
      "hbs",
    },
    config = function()
      require("nvim-ts-autotag").setup {
        filetypes = {
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "tsx",
          "jsx",
          "rescript",
          "xml",
          "php",
          "markdown",
          "astro",
          "glimmer",
          "handlebars",
          "hbs",
        },
        skip_tags = {
          "area",
          "base",
          "br",
          "col",
          "command",
          "embed",
          "hr",
          "img",
          "slot",
          "input",
          "keygen",
          "link",
          "meta",
          "param",
          "source",
          "track",
          "wbr",
          "menuitem",
        },
      }
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        virtual_text = {
          spacing = 5,
          severity_limit = "Warning",
        },
        update_in_insert = true,
      })
    end,
  },

  {
    "tpope/vim-obsession",
    lazy = false,
    cmd = { "Obsess" },
  },

  {
    "mfussenegger/nvim-jdtls",
    filetypes = { "java", "*.properties", "*.gradle" },
    event = "BufEnter *.java",
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

return plugins
