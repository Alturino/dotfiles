return {
  {
    "williamboman/mason.nvim",
    opts = {
      log_level = vim.log.levels.DEBUG,
      registries = {
        "github:nvim-java/mason-registry",
        "github:mason-org/mason-registry",
      },
      ensure_installed = {
        -- LSP
        "angular-language-server",
        "ansible-language-server",
        "bash-language-server",
        "clangd",
        "css-lsp",
        "cssmodules-language-server",
        "deno",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "emmet-ls",
        "eslint-lsp",
        "golangci-lint-langserver",
        "gopls",
        "gradle-language-server",
        "graphql-language-service-cli",
        "groovy-language-server",
        "helm-ls",
        "html-lsp",
        "jdtls",
        "json-lsp",
        "ltex-ls",
        "lua-language-server",
        "marksman",
        "mypy",
        "prisma-language-server",
        "pyright",
        "ruff-lsp",
        "rust-analyzer",
        "spectral-language-server",
        "sqlls",
        "svelte-language-server",
        "tailwindcss-language-server",
        "terraform-ls",
        "texlab",
        "tflint",
        "typescript-language-server",
        "typst-lsp",
        "vim-language-server",
        "vue-language-server",
        "yaml-language-server",

        -- Linter
        "actionlint",
        "commitlint",
        "cpplint",
        "eslint_d",
        "gitlint",
        "golangci-lint",
        "jsonlint",
        "revive",
        "shellcheck",
        "shellharden",
        "sqlfluff",
        "staticcheck",
        "stylelint",
        "textlint",
        "tflint",
        "tfsec",
        "vint",
        "yamllint",

        -- Formater
        "clang-format",
        "gofumpt",
        "goimports",
        "goimports-reviser",
        "golines",
        "gomodifytags",
        "gotests",
        "latexindent",
        "prettierd",
        "shellharden",
        "stylua",
        "xmlformatter",
        "yamlfmt",

        -- DAP
        "bash-debug-adapter",
        "codelldb",
        "cpptools",
        "dart-debug-adapter",
        "debugpy",
        "delve",
        "firefox-debug-adapter",
        "go-debug-adapter",
        "java-debug-adapter",
        "java-test",
        "js-debug-adapter",
        "node-debug2-adapter",
      },
    },
    build = ":MasonUpdate",
    dependencies = { "williamboman/mason-lspconfig" },
  },
}
