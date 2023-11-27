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
          local helpers = require "null-ls.helpers"
          local methods = require "null-ls.methods"
          local FORMATTING = methods.internal.FORMATTING

          local prismaFmt = helpers.make_builtin {
            name = "prismaFmt",
            meta = {
              url = "https://github.com/prisma/prisma-engines",
              description = "Formatter for the prisma file type",
            },
            method = FORMATTING,
            filetypes = { "prisma" },
            generator_opts = {
              command = { "prisma" },
              args = { "format", "$FILENAME" },
              to_stdin = false,
            },
            factory = function(opts)
              if opts.ignore_stderr == nil then
                opts.ignore_stderr = true
              end

              if opts.to_temp_file then
                opts.from_temp_file = true
              end

              opts.on_output = function(_, done)
                return done()
              end

              return helpers.generator_factory(opts)
            end,
          }

          local f = null_ls.builtins.formatting
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
            d.luacheck,
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
            f.clang_format.with { filetypes = { "c", "cpp" } },
            f.dart_format,
            f.eslint_d,
            f.gofumpt,
            f.goimports,
            f.goimports_reviser,
            f.golines,
            f.google_java_format,
            f.ktlint,
            f.latexindent,
            f.prettierd,
            prismaFmt,
            f.rubocop,
            f.ruff.with { command = { "ruff", "format" }, args = { "-n", "--stdin-filename", "$FILENAME" } },
            f.shellharden,
            f.sqlfmt,
            f.stylua,
            f.xmlformat,
            f.yamlfmt,
          }

          local vim = vim
          local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
          return {
            debug = true,
            sources = sources,
            on_attach = function(client, bufnr)
              if client.supports_method "textDocument/formatting" then
                vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
                vim.api.nvim_create_autocmd("BufWritePre", {
                  group = augroup,
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.buf.format {
                      bufnr = bufnr,
                      filter = function(c)
                        return c.name == "null-ls"
                      end,
                    }
                  end,
                })
              end
            end,
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
    dependencies = { "hrsh7th/cmp-nvim-lsp-signature-help" },
    opts = {
      sources = {
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lua" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      },
    },
  },
}

return plugins
