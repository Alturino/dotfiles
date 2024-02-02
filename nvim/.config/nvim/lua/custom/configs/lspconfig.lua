local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

require("neodev").setup {
  library = { plugins = { "nvim-dap-ui" }, types = true },
}

require "custom.configs.jdtls"

local lspconfig = require "lspconfig"

local default_config_servers = {
  "angularls",
  "ansiblels",
  "bashls",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "emmet_ls",
  "gopls",
  "gradle_ls",
  "graphql",
  "groovyls",
  "helm_ls",
  "html",
  "jsonls",
  "ltex",
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
  "yamlls",
}

for _, lsp in ipairs(default_config_servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
  },
}

lspconfig.cssmodules_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "typescriptreact", "javascriptreact", "tsx", "jsx" },
}

lspconfig.eslint.setup {
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
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "go", "gomod", "gosum" },

  init_options = {
    command = { "golangci-lint", "run", "--out-format", "json", "--allow-parallel-runners" },
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

lspconfig.stylelint_lsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "css",
    "less",
    "scss",
    "vue",
    "javascriptreact",
    "typescriptreact",
  },
}

lspconfig.tailwindcss.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "aspnetcorerazor",
    "astro",
    "htmldjango",
    "ejs",
    "erb",
    "gohtml",
    "gohtmltmpl",
    "html",
    "mdx",
    "php",
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
  },
}

lspconfig.tsserver.setup {
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  capabilities = capabilities,
}
