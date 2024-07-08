return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "nvimtools/none-ls.nvim",
      "b0o/schemastore.nvim",
      "nvim-java/nvim-java",
    },
    init = function()
      vim.lsp.set_log_level("debug")
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
        sqlls = {},
        svelte = {},
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
        golangci_lint_ls = {
          filetypes = { "go", "gomod", "gosum" },

          init_options = {
            command = { "golangci-lint", "run", "--out-format", "json", "--allow-parallel-runners" },
          },
        },
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
      },
    },
  },
}
