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
  "cssmodules_ls",
  "denols",
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
  "tailwindcss",
  "terraformls",
  "texlab",
  "tflint",
  "tsserver",
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

lspconfig.golangci_lint_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "go", "gomod", "gosum" },

  init_options = {
    command = { "golangci-lint", "run", "--out-format", "json", "--allow-parallel-runners" },
  },
}

lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
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
