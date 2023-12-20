local on_attach = function(client, bufnr)
  require("plugins.configs.lspconfig").on_attach(client, bufnr)
  if client.name == "ruff_lsp" then
    client.server_capabilities.hoverProvider = false
  end
  if client.name == "yamlls" then
    client.server_capabilities.documentFormattingProvider = true
  end
  if client.name == "jdtls" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end
local capabilities = require("plugins.configs.lspconfig").capabilities
capabilities.textDocument.completion.completionItem.snippetSupport = true

require("neodev").setup {
  library = { plugins = { "nvim-dap-ui" }, types = true },
}

require "custom.configs.jdtls"

local lspconfig = require "lspconfig"

local default_config_servers = {
  "bashls",
  "docker_compose_language_service",
  "dockerls",
  "gopls",
  "gradle_ls",
  "groovyls",
  "html",
  "jsonls",
  "ltex",
  "marksman",
  "nil_ls",
  "prismals",
  "pyright",
  "rnix",
  "rubocop",
  "ruff_lsp",
  "rust_analyzer",
  "sorbet",
  "sqlls",
  "svelte",
  "terraformls",
  "texlab",
  "tflint",
  "tsserver",
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

lspconfig.kotlin_language_server.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "kotlin" },
  cmd = { "kotlin-language-server" },
  root_dir = lspconfig.util.root_pattern("", "build.gradle", "gradlew", ".git"),
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

lspconfig.tailwindcss.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "astro",
    "html",
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

lspconfig.emmet_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "css",
    "html",
    "htmldjango",
    "javascriptreact",
    "less",
    "pug",
    "sass",
    "scss",
    "svelte",
    "typescriptreact",
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
