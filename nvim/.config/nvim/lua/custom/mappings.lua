---@type MappingsTable
local M = {}

M.general = {
  n = {
    -- resize buffer
    ["<C-Up>"] = { "<C-w>+", "Increase buffer height", opts = { nowait = true, noremap = true } },
    ["<C-Down>"] = { "<C-w>-", "Decrease buffer height", opts = { nowait = true, noremap = true } },
    ["<C-Left>"] = { "<C-w><", "Decrease buffer width", opts = { nowait = true, noremap = true } },
    ["<C-Right>"] = { "<C-w>>", "Increase buffer width", opts = { nowait = true, noremap = true } },

    -- Split window
    ["<leader>vs"] = {
      "<Cmd>vsplit<CR><C-l>",
      "[V]ertical [S]plit Window",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>hs"] = {
      "<Cmd>split<CR><C-j>",
      "[H]orizontal [S]plit Window",
      opts = { nowait = true, noremap = true },
    },

    -- Scroll half and focus center
    ["<C-d>"] = { "<C-d>zz", "Scroll down and focus center", opts = { nowait = true, noremap = true } },
    ["<C-u>"] = { "<C-u>zz", "Scroll up and focus center", opts = { nowait = true, noremap = true } },
    ["<leader>fm"] = {
      function()
        vim.lsp.buf.format { async = true }
      end,
      "LSP formatting",
    },
  },
}

M.disabled = {
  n = {
    ["<leader>v"] = "",
    ["<leader>h"] = "",
    ["<A-i>"] = "",
  },
}

M.tabufline = {
  n = {
    ["<leader>xa"] = {
      function()
        require("nvchad.tabufline").closeOtherBufs()
      end,
      "Close buffers except current buffer",
      opts = { nowait = true, noremap = true },
    },
    ["[b"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"

        local n = function()
          require("nvchad.tabufline").tabuflineNext()
        end

        local p = function()
          return require("nvchad.tabufline").tabuflinePrev()
        end

        local _, prev = ts_move.make_repeatable_move_pair(n, p)

        return prev()
      end,
      "Goto prev buffer",
      opts = { nowait = true, noremap = true },
    },
    ["]b"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"

        local n = function()
          require("nvchad.tabufline").tabuflineNext()
        end

        local p = function()
          return require("nvchad.tabufline").tabuflinePrev()
        end

        local next, _ = ts_move.make_repeatable_move_pair(n, p)

        return next()
      end,
      "Goto next buffer",
      opts = { nowait = true, noremap = true },
    },
  },
}

M.treesitter_context = {
  n = {
    ["<leader>tct"] = {
      "<cmd>TSContextToggle<cr>",
      "Treesitter context toggle",
    },
  },
}

M.dadbod_ui = {
  n = {
    ["<leader>dbt"] = {
      "<cmd>DBUIToggle<cr>",
      "Dadbod ui toggle",
    },
    ["<leader>dba"] = {
      "<cmd>DBUIAddConnection<cr>",
      "Dadbod ui add connection",
    },
  },
}

M.harpoon = {
  n = {
    ["<leader>ha"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():append()
      end,
      "Harpoon Add",
    },
    ["<leader>hm"] = {
      function()
        local harpoon = require "harpoon"
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      "Harpoon Menu",
    },
    ["<leader>h1"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():select(1)
      end,
      "Harpoon 1",
    },
    ["<leader>h2"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():select(2)
      end,
      "Harpoon 2",
    },
    ["<leader>h3"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():select(3)
      end,
      "Harpoon 3",
    },
    ["<leader>h4"] = {
      function()
        local harpoon = require "harpoon"
        harpoon:list():select(4)
      end,
      "Harpoon 4",
    },
    ["<leader>hls"] = {
      function()
        local harpoon = require "harpoon"
        harpoon.logger:show()
      end,
      "Harpoon logger show",
    },
  },
}

M.telescope = {
  n = {
    ["<leader>fh"] = {
      "<cmd>Telescope harpoon marks<cr>",
      "Find Harpoon",
    },
    ["<leader>ff"] = {
      "<cmd>Telescope find_files no_ignore=false hidden=true<cr>",
      "Find files",
    },
    ["<leader>fs"] = {
      function()
        require("telescope.builtin").lsp_workspace_symbols()
      end,
      "Find symbols",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>fu"] = {
      function()
        require("telescope.builtin").lsp_references()
      end,
      "Find Usages",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>fic"] = {
      function()
        require("telescope.builtin").lsp_incoming_calls()
      end,
      "Find lsp incoming call",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>foc"] = {
      function()
        require("telescope.builtin").lsp_outgoing_calls()
      end,
      "Find lsp outgoing call",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>gc"] = {
      function()
        require("telescope.builtin").git_commits()
      end,
      "Git commits",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>gb"] = {
      function()
        require("telescope.builtin").git_branches()
      end,
      "Git branches",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>gs"] = {
      function()
        require("telescope.builtin").git_status()
      end,
      "Git status",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>gst"] = {
      function()
        require("telescope.builtin").git_stash()
      end,
      "Git stash",
      opts = { nowait = true, noremap = true },
    },
  },
}

M.lspconfig = {
  n = {
    ["<leader>tf"] = {
      function()
        vim.lsp.buf.type_definition()
      end,
      "Type definition",
      opts = { nowait = true, noremap = true },
    },

    ["[w"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local v = vim

        local n = function()
          return v.diagnostic.goto_next {
            severity = v.diagnostic.severity.WARN,
            float = { border = "rounded" },
          }
        end

        local p = function()
          v.diagnostic.goto_prev {
            severity = v.diagnostic.severity.WARN,
            float = { border = "rounded" },
          }
        end

        local _, prev = ts_move.make_repeatable_move_pair(n, p)

        return prev()
      end,
      "Goto previous warning",
      opts = { nowait = true, noremap = true },
    },

    ["]w"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local v = vim

        local n = function()
          return v.diagnostic.goto_next {
            severity = v.diagnostic.severity.WARN,
            float = { border = "rounded" },
          }
        end

        local p = function()
          v.diagnostic.goto_prev {
            severity = v.diagnostic.severity.WARN,
            float = { border = "rounded" },
          }
        end

        local next, _ = ts_move.make_repeatable_move_pair(n, p)

        return next()
      end,
      "Goto next warning",
      opts = { nowait = true, noremap = true },
    },

    ["]e"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local v = vim

        local n = function()
          return v.diagnostic.goto_next {
            severity = v.diagnostic.severity.ERROR,
            float = { border = "rounded" },
          }
        end

        local p = function()
          v.diagnostic.goto_prev {
            severity = v.diagnostic.severity.ERROR,
            float = { border = "rounded" },
          }
        end

        local next, _ = ts_move.make_repeatable_move_pair(n, p)

        return next()
      end,
      "Goto previous error",
      opts = { nowait = true, noremap = true },
    },

    ["[e"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local v = vim

        local n = function()
          return v.diagnostic.goto_next {
            severity = v.diagnostic.severity.ERROR,
            float = { border = "rounded" },
          }
        end

        local p = function()
          v.diagnostic.goto_prev {
            severity = v.diagnostic.severity.ERROR,
            float = { border = "rounded" },
          }
        end

        local _, prev = ts_move.make_repeatable_move_pair(n, p)

        return prev()
      end,
      "Goto next error",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>cA"] = {
      function()
        vim.lsp.buf.code_action {
          context = {
            only = {
              "source",
            },
            diagnostics = {},
          },
        }
      end,
      "Source Action",
      opts = { nowait = true, noremap = true },
    },
  },
}

M.tmux = {
  n = {
    ["<C-h>"] = {
      "<Cmd>TmuxNavigateLeft<CR>",
      "Navigate tmux window left",
      opts = { nowait = true, noremap = true },
    },

    ["<C-j>"] = {
      "<Cmd>TmuxNavigateDown<CR>",
      "Navigate tmux window down",
      opts = { nowait = true, noremap = true },
    },

    ["<C-k>"] = {
      "<Cmd>TmuxNavigateUp<CR>",
      "Navigate tmux window up",
      opts = { nowait = true, noremap = true },
    },

    ["<C-l>"] = {
      "<Cmd>TmuxNavigateRight<CR>",
      "Navigate tmux window right",
      opts = { nowait = true, noremap = true },
    },
  },
}

M.dap = {
  n = {
    ["<leader>sd"] = {
      function()
        require("dap").continue()
      end,
      "Start debugging",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>so"] = {
      function()
        require("dap").step_over()
      end,
      "Step over",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>su"] = {
      function()
        require("dap").step_out()
      end,
      "Step out",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>si"] = {
      function()
        require("dap").step_into()
      end,
      "Step into",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>dt"] = {
      function()
        require("dapui").toggle()
      end,
      "Debug toggle",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>bp"] = {
      function()
        require("dap").toggle_breakpoint()
      end,
      "Toggle break point",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>cbp"] = {
      function()
        require("dap").set_breakpoint(vim.fn.input "Conditional breakpoint: ")
      end,
      "Conditional break point",
      opts = { nowait = true, noremap = true },
    },
  },
}

M.treesitter = {
  n = {
    [";"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.repeat_last_move()
      end,
      "Treesitter Repeat Last Move Next",
    },

    [","] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.repeat_last_move_opposite()
      end,
      "Treesitter Repeat Last Move Previous",
    },

    ["f"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_f()
      end,
      "Treesitter Repeat Builtin f",
    },

    ["F"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_F()
      end,
      "Treesitter Repeat Builtin F",
    },

    ["t"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_t()
      end,
      "Treesitter Repeat Builtin t",
    },

    ["T"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_T()
      end,
      "Treesitter Repeat Builtin T",
    },
  },
  o = {
    [";"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.repeat_last_move()
      end,
      "Treesitter Repeat Last Move Next",
    },

    [","] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.repeat_last_move_opposite()
      end,
      "Treesitter Repeat Last Move Previous",
    },

    ["f"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_f()
      end,
      "Treesitter Repeat Builtin f",
    },

    ["F"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_F()
      end,
      "Treesitter Repeat Builtin F",
    },

    ["t"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_t()
      end,
      "Treesitter Repeat Builtin t",
    },

    ["T"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_T()
      end,
      "Treesitter Repeat Builtin T",
    },
  },
  x = {
    [";"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.repeat_last_move()
      end,
      "Treesitter Repeat Last Move Next",
    },

    [","] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.repeat_last_move_opposite()
      end,
      "Treesitter Repeat Last Move Previous",
    },

    ["f"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_f()
      end,
      "Treesitter Repeat Builtin f",
    },

    ["F"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_F()
      end,
      "Treesitter Repeat Builtin F",
    },

    ["t"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_t()
      end,
      "Treesitter Repeat Builtin t",
    },

    ["T"] = {
      function()
        local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
        return ts_repeat_move.builtin_T()
      end,
      "Treesitter Repeat Builtin T",
    },
  },
}

M.trouble = {
  n = {
    ["<leader>tt"] = {
      "<Cmd>TroubleToggle<CR>",
      "Trouble toggle",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>wd"] = {
      "<Cmd>TroubleToggle workspace_diagnostics<CR>",
      "TroubleToggle workspace diagnostics",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>qf"] = {
      "<Cmd>TroubleToggle quickfix<CR>",
      "TroubleToggle quick fix",
      opts = { nowait = true, noremap = true },
    },
  },
}

M.gitsigns = {
  n = {
    ["[h"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local gs = require "gitsigns"
        local _, prev_hunk = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        return prev_hunk()
      end,
      "Goto previous hunk",
    },
    ["]h"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local gs = require "gitsigns"
        local next_hunk, _ = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        return next_hunk()
      end,
      "Goto next hunk",
    },
  },

  x = {
    ["]h"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local gs = require "gitsigns"
        local next_hunk, prev_hunk = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        return next_hunk(), prev_hunk()
      end,
      "Goto previous hunk",
    },
    ["[h"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local gs = require "gitsigns"
        local next_hunk, prev_hunk = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        return next_hunk(), prev_hunk()
      end,
      "Goto next hunk",
    },
  },

  o = {
    ["]h"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local gs = require "gitsigns"
        local next_hunk, prev_hunk = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        return next_hunk(), prev_hunk()
      end,
      "Goto previous hunk",
    },
    ["[h"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local gs = require "gitsigns"
        local next_hunk, prev_hunk = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        return next_hunk(), prev_hunk()
      end,
      "Goto next hunk",
    },
  },
}

return M
