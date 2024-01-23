-- This is only for overriding the default plugin from nvchad, adding plugin than default plugin go to plugins directory
local overrides = require "custom.configs.overrides"
---@type NvPluginSpec[]
local plugins = {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "jose-elias-alvarez/null-ls.nvim",
        opts = function()
          local null_ls = require "null-ls"
          local d = null_ls.builtins.diagnostics
          local ca = null_ls.builtins.code_actions

          local sources = {
            ca.eslint_d,
            ca.gitsigns,
            ca.gomodifytags,
            ca.impl,
            ca.refactoring,
            d.actionlint,
            d.commitlint,
            d.cpplint,
            d.eslint_d,
            d.gitlint,
            d.golangci_lint,
            d.hadolint,
            d.jsonlint,
            d.ktlint,
            d.revive,
            d.rubocop,
            d.ruff.with { command = { "ruff", "check" }, args = { "-n", "--stdin-filename", "$FILENAME" } },
            d.shellcheck,
            d.sqlfluff,
            d.staticcheck,
            d.stylelint,
            d.textlint,
            d.tfsec,
            d.vint,
            d.yamllint,
          }

          return {
            debug = true,
            sources = sources,
          }
        end,
        config = function(_, opts)
          require("null-ls").setup(opts)
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
    dependencies = { "williamboman/mason-lspconfig" },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {},
        config = function(_, opts)
          require("treesitter-context").setup(opts)
        end,
        cmd = { "TSContextEnable", "TSContextDisable", "TSContextToggle" },
      },
    },
    event = "BufReadPre",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope-ui-select.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
      },
    },
    cmd = "Telescope",
    opts = overrides.telescope,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp-signature-help", "kristijanhusak/vim-dadbod-completion" },
    opts = {
      sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "vim-dadbod-completion" },
        { name = "nvim_lua" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      },
    },
  },
}

return plugins
