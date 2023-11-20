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
    build = "make",
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
    config = function()
      vim.keymap.set("n", "<leader>rn", "<cmd>GoRun<cr>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>ri", "<cmd>GoInstall<cr>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>rb", "<cmd>GoBuild<cr>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>rt", "<cmd>GoTest<cr>", { silent = true, noremap = true })
    end,
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
  },

  {
    "ThePrimeagen/vim-be-good",
    cmd = { "VimBeGood" },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui" },
      {
        "jay-babu/mason-nvim-dap.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        config = function()
          require("dapui").setup()
          require("mason-nvim-dap").setup {
            automatic_setup = overrides.mason_dap.automatic_setup,
            ensure_installed = overrides.mason_dap.ensure_installed,
            automatic_installation = overrides.mason_dap.automatic_installation,
          }
        end,
      },
      {
        "leoluz/nvim-dap-go",
        ft = "go",
        opts = overrides.dap_go,
        config = function(_, opts)
          require("dap-go").setup(opts)
        end,
      },
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
          require("dap-python").setup(debugpy_executable)
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
      require("refactoring").setup {
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
      "neovim/nvim-lspconfig",
      "dart-lang/dart-vim-plugin",
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = function()
      local on_attach = require("plugins.configs.lspconfig").on_attach
      local capabilities = require("plugins.configs.lspconfig").capabilities
      require("flutter-tools").setup {
        dev_tools = {
          autostart = true,
          auto_open_browser = true,
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
      vim.keymap.set("n", "<leader>rn", "<CMD>FlutterRun<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>fd", "<CMD>FlutterDevices<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>fe", "<CMD>FlutterEmulators<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>fr", "<CMD>FlutterReload<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>fR", "<CMD>FlutterRestart<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>fq", "<CMD>FlutterQuit<CR>", { noremap = true, silent = true })
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

  {
    "dart-lang/dart-vim-plugin",
    ft = { "dart" },
    event = "BufEnter *.dart",
  },
}

return plugins
