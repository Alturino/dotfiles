local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "cpp",
    "dockerfile",
    "gitignore",
    "json",
    "latex",
    "lua",
    "go",
    "kotlin",
    "java",
    "python",
    "ruby",
    "rust",
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
  "pylyzer",
  "prisma-language-server",
  "json-lsp",
  "eslint-lsp",
  "cssmodules-language-server",
  "dockerfile-language-server",
  "docker-compose-language-service",
  "tailwindcss-language-server",
  "vetur-vls",
  "vue-language-server",
  "yaml-language-server",
  "svelte-language-server",
  "pyre",
  "vim-language-server",
  "terraform-ls",
  "rust-analyzer",
  "python-lsp-server",
  "ruby-lsp",
  "golangci-lint-langserver",
  "sqlls",
  "clangd",
  "marksman",
  "pyright",
  "gopls",
  "css-lsp",
  "deno",
  "html-lsp",
  "ltex-ls",
  "lua-language-server",
  "texlab",
  "tflint",
  "typescript-language-server",
  "jdtls",
  "emmet-ls",
  "nginx-language-server",

  -- Linter
  "luacheck",
  "shellharden",
  "pyre",
  "actionlint",
  "commitlint",
  "cpplint",
  "eslint_d",
  "flake8",
  "gitlint",
  "golangci-lint",
  "hadolint",
  "jsonlint",
  "ktlint",
  "mypy",
  "pydocstyle",
  "pyflakes",
  "pylama",
  "pylint",
  "revive",
  "shellcheck",
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
  "shellharden",
  "clang-format",
  "xmlformatter",
  "goimports-reviser",
  "prettierd",
  "sqlfmt",
  "goimports",
  "gomodifytags",
  "golines",
  "gofumpt",
  "autoflake",
  "latexindent",
  "autopep8",
  "yamlfmt",
  "black",
  "isort",
  "gotests",
  "stylua",
  "ktlint",
  "prettier",
  "ts-standard",

  -- DAP
  "firefox-debug-adapter",
  "node-debug2-adapter",
  "js-debug-adapter",
  "cpptools",
  "bash-debug-adapter",
  "codelldb",
  "dart-debug-adapter",
  "debugpy",
  "delve",
  "go-debug-adapter",
  "java-debug-adapter",
  "java-test",
  "kotlin-debug-adapter",
}

M.mason = {
  ensure_installed = must_installed,
}

M.mason_lspconfig = {
  automatic_installation = true,
  ensure_installed = must_installed,
}

-- git support in nvimtree
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

M.mason_dap = {
  automatic_installation = true,
  automatic_setup = true,
  ensure_installed = {
    "cppdbg",
    "delve",
    "javadbg",
    "javatest",
    "kotlin",
    "bash",
    "js",
    "python",
    "dart",
    "delve",
    "firefox",
  },
}

M.dapui = {
  icons = {
    expanded = "▾",
    collapsed = "▸",
    current_frame = "*",
  },
  controls = {
    icons = {
      pause = "⏸",
      play = "▶",
      step_into = "⏎",
      step_over = "⏭",
      step_out = "⏮",
      step_back = "b",
      run_last = "▶▶",
      terminate = "⏹",
      disconnect = "⏏",
    },
  },
}

M.telescope = {
  extensions_list = { "themes", "terms", "fzf", "notify" },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
}

local cmp = require "cmp"
M.cmp = {
  sources = cmp.config.sources({
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "nvim_lsp_signature_help" },
    { name = "luasnip" },
    -- {name = "copilot"},
  }, {
    { name = "path" },
    { name = "buffer" },
  }),
  mapping = {
    ["<CR>"] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
    ["<C-u>"] = cmp.mapping.scroll_docs(4),
    ["<Tab>"] = cmp.mapping(function(fallback)
      -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
      if cmp.visible() then
        local entry = cmp.get_selected_entry()
        if not entry then
          cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
        else
          cmp.confirm()
        end
      else
        fallback()
      end
    end, { "i", "s", "c" }),
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,

      function(entry1, entry2)
        local _, entry1_under = entry1.completion_item.label:find "^_+"
        local _, entry2_under = entry2.completion_item.label:find "^_+"
        entry1_under = entry1_under or 0
        entry2_under = entry2_under or 0
        if entry1_under > entry2_under then
          return false
        elseif entry1_under < entry2_under then
          return true
        end
      end,

      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  experimental = {
    native_menu = false,
    ghost_text = false,
  },
}

M.dap_go = {
  dap_configurations = {
    {
      -- Must be "go" or it will be ignored by the plugin
      type = "go",
      name = "Attach remote",
      mode = "remote",
      request = "attach",
    },
  },
  delve = {
    -- the path to the executable dlv which will be used for debugging.
    -- by default, this is the "dlv" executable on your PATH.
    path = "dlv",
    -- time to wait for delve to initialize the debug session.
    -- default to 20 seconds
    initialize_timeout_sec = 20,
    -- a string that defines the port to start delve debugger.
    -- default to string "${port}" which instructs nvim-dap
    -- to start the process in a random available port
    port = "${port}",
    -- additional args to pass to dlv
    args = {},
  },
}

return M
