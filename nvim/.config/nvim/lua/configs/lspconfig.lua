local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

require "configs.jdtls"

local lspconfig = require "lspconfig"

local default_config_servers = {
  "angularls",
  "ansiblels",
  "bashls",
  "cssls",
  "dockerls",
  "emmet_ls",
  "gopls",
  "gradle_ls",
  "graphql",
  "groovyls",
  "helm_ls",
  "marksman",
  "prismals",
  "pyright",
  "rubocop",
  "ruff_lsp",
  "rust_analyzer",
  "spectral",
  "sqlls",
  "svelte",
  "terraformls",
  "texlab",
  "tflint",
  "typst_lsp",
  "vimls",
  "vuels",
}

for _, lsp in ipairs(default_config_servers) do
  lspconfig[lsp].setup {
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.clangd.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
  },
}

lspconfig.cssmodules_ls.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "typescriptreact", "javascriptreact" },
}

lspconfig.docker_compose_language_service.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "yaml", "yml", "yaml.docker-compose" },
}

lspconfig.eslint.setup {
  on_init = on_init,
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}

lspconfig.golangci_lint_ls.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "go", "gomod", "gosum" },

  init_options = {
    command = { "golangci-lint", "run", "--out-format", "json", "--allow-parallel-runners" },
  },
}

lspconfig.html.setup {
  on_init = on_init,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  capabilities = capabilities,
  filetypes = { "html", "typescriptreact", "javascriptreact" },
}

lspconfig.jsonls.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    json = {
      validate = { enable = true },
      schemas = require("schemastore").json.schemas(),
    },
  },
}

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace",
      },
    },
  },
}

lspconfig.ltex.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "latex" },
}

lspconfig.stylelint_lsp.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "css",
    "javascriptreact",
    "less",
    "scss",
    "typescriptreact",
    "vue",
  },
}

lspconfig.tailwindcss.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
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
}

lspconfig.tsserver.setup {
  on_init = on_init,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  capabilities = capabilities,
}

lspconfig.yamlls.setup {
  on_init = on_init,
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    redhat = {
      telemetry = {
        enabled = false,
      },
    },
    yaml = {
      schemaStore = { enable = false, url = "" },
      schemas = require("schemastore").yaml.schemas {
        extra = {
          {
            description = "kubernetes json schema",
            fileMatch = "*.{yaml, yml}",
            name = "kubernetes",
            url = "https://kubernetesjsonschema.dev/master/all.json",
          },
        },
      },
    },
  },
}
