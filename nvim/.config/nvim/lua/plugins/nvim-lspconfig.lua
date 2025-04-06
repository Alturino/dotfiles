return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "nvimtools/none-ls.nvim",
      "b0o/SchemaStore.nvim",
      "nvim-java/nvim-java",
      "nanotee/sqls.nvim",
    },
    init = function()
      vim.lsp.set_log_level("error")
    end,
    opts = {
      servers = {
        angularls = {},
        ansiblels = {},
        awk_ls = {},
        bashls = {},
        cssls = {},
        docker_compose_language_service = {},
        dockerls = {},
        emmet_ls = {},
        eslint = {},
        gopls = {},
        gradle_ls = {},
        ast_grep = {},
        graphql = {},
        groovyls = {},
        helm_ls = {},
        jdtls = {},
        marksman = {},
        prismals = {},
        rubocop = {},
        ruff_lsp = {},
        rust_analyzer = {},
        spectral = {},
        sqls = {
          cmd = { "sqls", "-config", LazyVim.root.cwd() .. "/config.yml" },
          on_attach = function(client, buffer)
            require("sqls").on_attach(client, buffer)
          end,
        },
        postgres_lsp = {},
        sqlls = {},
        svelte = {},
        sourcekit = {},
        terraformls = {},
        texlab = {},
        tflint = {},
        tsserver = {},
        typst_lsp = {},
        vimls = {},
        vuels = {},
        clangd = {
          cmd = {
            "clangd",
            "--offset-encoding=utf-16",
          },
        },
        cssmodules_ls = {
          filetypes = { "typescriptreact", "javascriptreact" },
        },
        golangci_lint_ls = {},
        html = {
          filetypes = { "html", "typescriptreact", "javascriptreact" },
        },
        jsonls = {
          settings = {
            json = {
              validate = { enable = true },
              schemas = require("schemastore").json.schemas(),
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        ltex = {
          filetypes = { "latex" },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                typeCheckingMode = "basic",
              },
            },
          },
        },
        stylelint_lsp = {
          filetypes = {
            "css",
            "javascriptreact",
            "less",
            "scss",
            "typescriptreact",
            "vue",
          },
        },
        tailwindcss = {
          filetypes = {
            "aspnetcorerazor",
            "astro",
            "css",
            "ejs",
            "erb",
            "gohtml",
            "gohtmltmpl",
            "html",
            "htmldjango",
            "javascriptreact",
            "less",
            "mdx",
            "php",
            "postcss",
            "sass",
            "scss",
            "svelte",
            "typescriptreact",
            "vue",
          },
        },
        yamlls = {
          settings = {
            redhat = {
              telemetry = {
                enabled = false,
              },
            },
            yaml = {
              schemaStore = { enable = false, url = "" },
              schemas = require("schemastore").yaml.schemas({
                extra = {
                  {
                    description = "kubernetes json schema",
                    fileMatch = "*.{yaml, yml}",
                    name = "kubernetes",
                    url = "https://kubernetesjsonschema.dev/master/all.json",
                  },
                },
              }),
            },
          },
        },
      },
      setup = {
        jdtls = function()
          require("java").setup({})
        end,
        vtsls = function(server)
          LazyVim.lsp.on_attach(function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end, server)
        end,
        denols = function(server)
          LazyVim.lsp.on_attach(function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end, server)
        end,
        html = function(server)
          LazyVim.lsp.on_attach(function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end, server)
        end,
        tsserver = function(server)
          LazyVim.lsp.on_attach(function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end, server)
        end,
        jsonls = function(server)
          LazyVim.lsp.on_attach(function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end, server)
        end,
        docker_compose_language_service = function(server)
          LazyVim.lsp.on_attach(function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end, server)
        end,
        sqls = function(server)
          LazyVim.lsp.on_attach(function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end, server)
        end,
        sqlls = function(server)
          LazyVim.lsp.on_attach(function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end, server)
        end,
      },
    },
  },
}
