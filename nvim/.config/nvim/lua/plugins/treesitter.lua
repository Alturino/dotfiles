return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
          enable = true,    -- Enable this plugin (Can be enabled/disabled later via commands)
          max_lines = 0,    -- How many lines the window should span. Values <= 0 mean no limit.
          min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
          line_numbers = true,
          multiline_threshold = 20, -- Maximum number of lines to show for a single context
          trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
          mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
          -- Separator between context and content. Should be a single character string, like '-'.
          -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
          separator = nil,
          zindex = 20, -- The Z-index of the context window
          on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        },
        config = function(_, opts)
          require("treesitter-context").setup(opts)
        end,
        cmd = { "TSContextEnable", "TSContextDisable", "TSContextToggle" },
      },
    },
    event = "BufReadPre",
    opts = {
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
            ["@function.outer"] = "V",  -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
          },
          keymaps = {
            ["ia"] = "@parameter.outer",   -- a = args\ arguments
            ["aa"] = "@parameter.inner",
            ["af"] = "@function.outer",    -- f = function
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",       -- c = class
            ["ic"] = "@class.inner",
            ["il"] = "@loop.inner",        -- l = loop
            ["al"] = "@loop.outer",
            ["ib"] = "@block.inner",       -- b = block
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
    },
  },
}
