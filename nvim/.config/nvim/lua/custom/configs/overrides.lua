local M = {}

M.treesitter = {
  ensure_installed = {
    "bash",
    "bibtex",
    "c",
    "cmake",
    "cpp",
    "css",
    "csv",
    "dart",
    "dockerfile",
    "fish",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "go",
    "gomod",
    "gosum",
    "gowork",
    "gpg",
    "graphql",
    "groovy",
    "hocon",
    "html",
    "htmldjango",
    "http",
    "java",
    "javascript",
    "json",
    "jsonnet",
    "kotlin",
    "latex",
    "lua",
    "luadoc",
    "make",
    "markdown",
    "markdown_inline",
    "nix",
    "prisma",
    "proto",
    "python",
    "regex",
    "ruby",
    "rust",
    "sql",
    "ssh_config",
    "svelte",
    "terraform",
    "textproto",
    "toml",
    "tsv",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "vue",
    "xml",
    "yaml",
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      selection_modes = {
        ["@parameter.outer"] = "v", -- charwise
        ["@function.outer"] = "V", -- linewise
        ["@class.outer"] = "<c-v>", -- blockwise
      },
      keymaps = {
        ["ia"] = "@parameter.outer", -- a = args\ arguments
        ["aa"] = "@parameter.inner",
        ["af"] = "@function.outer", -- f = function
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer", -- c = class
        ["ic"] = "@class.inner",
        ["il"] = "@loop.inner", -- l = loop
        ["al"] = "@loop.outer",
        ["ib"] = "@block.inner", -- b = block
        ["ab"] = "@block.outer",
        ["ad"] = "@conditional.outer", -- d = determiner / conditional
        ["id"] = "@conditional.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]f"] = { query = "@function.outer", desc = "Next function start" },
        ["]c"] = { query = "@class.outer", desc = "Next class start" },
        ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
        ["]d"] = { query = "@conditional.outer", desc = "Next conditional start" },
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_previous_start = {
        ["[f"] = { query = "@function.outer", desc = "Previous function start" },
        ["[c"] = { query = "@class.outer", desc = "Previous class start" },
        ["[l"] = { query = "@loop.outer", desc = "Previous loop start" },
        ["[d"] = { query = "@conditional.outer", desc = "Previous conditional start" },
        ["[s"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
        ["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
      },
      goto_next_end = {
        ["]F"] = { query = "@function.outer", desc = "Next function start" },
        ["]C"] = { query = "@class.outer", desc = "Next class start" },
        ["]L"] = { query = "@loop.outer", desc = "Next loop start" },
        ["]D"] = { query = "@conditional.outer", desc = "Next conditional start" },
        ["]S"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]Z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_previous_end = {
        ["[F"] = { query = "@function.outer", desc = "Previous function start" },
        ["[C"] = { query = "@class.outer", desc = "Previous class start" },
        ["[L"] = { query = "@loop.outer", desc = "Previous loop start" },
        ["[D"] = { query = "@conditional.outer", desc = "Previous conditional start" },
        ["[S"] = { query = "@scope", query_group = "locals", desc = "Previous scope" },
        ["[Z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
      },
    },
    lsp_interop = {
      enable = true,
      border = "none",
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>pf"] = "@function.outer",
        ["<leader>pc"] = "@class.outer",
      },
    },
  },
  autotag = {
    enable = true,
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
    filetypes = {
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
  },
}

local must_installed = {
  -- LSP
  "clangd",
  "css-lsp",
  "cssmodules-language-server",
  "docker-compose-language-service",
  "dockerfile-language-server",
  "emmet-ls",
  "eslint-lsp",
  "golangci-lint-langserver",
  "gopls",
  "html-lsp",
  "jdtls",
  "json-lsp",
  "ltex-ls",
  "lua-language-server",
  "marksman",
  "prisma-language-server",
  "ruff",
  "ruff-lsp",
  "rust-analyzer",
  "sqlls",
  "svelte-language-server",
  "tailwindcss-language-server",
  "terraform-ls",
  "texlab",
  "tflint",
  "typescript-language-server",
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
  "luacheck",
  "revive",
  "shellcheck",
  "shellharden",
  "sqlfluff",
  "staticcheck",
  "stylelint",
  "textlint",
  "tflint",
  "tfsec",
  "ts-standard",
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
  "prettier",
  "prettierd",
  "shellharden",
  "sqlfmt",
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
}

M.mason = {
  ensure_installed = must_installed,
}

M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

M.telescope = {
  extensions_list = {
    "fzf",
    "notify",
    "refactoring",
    "terms",
    "themes",
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
}

return M
