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
    ["<leader>v"] = {
      "<Cmd>vsplit<CR><C-l>",
      "[V]ertical [S]plit Window",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>h"] = {
      "<Cmd>split<CR><C-j>",
      "[H]orizontal [S]plit Window",
      opts = { nowait = true, noremap = true },
    },

    -- Buffer management
    ["<C-x>"] = { "<C-w>o", "Close all buffer except current buffer", opts = { nowait = true, noremap = true } },
    ["<leader>gn"] = { "<C-6>", "Goto Next Edited Buffer", opts = { nowait = true, noremap = true } },
    ["<leader>gp"] = { "<C-^>", "Goto Previous Edited Buffer", opts = { nowait = true, noremap = true } },

    -- Scroll half and focus center
    ["<C-d>"] = { "<C-d>zz", "Scroll down and focus center", opts = { nowait = true, noremap = true } },
    ["<C-u>"] = { "<C-u>zz", "Scroll up and focus center", opts = { nowait = true, noremap = true } },
  },
}

M.lspconfig = {
  n = {
    ["<leader>tf"] = {
      function()
        vim.lsp.buf.type_definition()
      end,
      "[T]ype De[F]inition",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>fs"] = {
      function()
        require("telescope.builtin").lsp_document_symbols()
      end,
      "[F]ind [S]ymbols",
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
      "[G]oto Diagnostics [P]revious",
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
      "[G]oto Diagnostics [N]ext",
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
      "Goto Next Error",
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
      "Goto Previous Error",
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
      "[S]tart [D]ebugging",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>so"] = {
      function()
        require("dap").step_over()
      end,
      "[S]tep [O]ver",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>su"] = {
      function()
        require("dap").step_out()
      end,
      "[S]tep o[U]t",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>si"] = {
      function()
        require("dap").step_into()
      end,
      "[S]tep [I]nto",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>td"] = {
      function()
        require("dapui").toggle()
      end,
      "[T]oggle [D]ebug",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>bp"] = {
      function()
        require("dap").toggle_breakpoint()
      end,
      "[T]oggle [B]reak[P]oint",
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
      "[T]rouble [T]oggle",
      opts = { nowait = true, noremap = true },
    },

    ["<leader>wd"] = {
      "<Cmd>TroubleToggle workspace_diagnostics<CR>",
      "TroubleToggle [W]orkspace [D]iagnostics",
      opts = { nowait = true, noremap = true },
    },
    ["<leader>qf"] = {
      "<Cmd>TroubleToggle quickfix<CR>",
      "TroubleToggle [Q]uick [F]ix",
      opts = { nowait = true, noremap = true },
    },
  },
}

M.refactoring = {
  x = {
    ["<leader>re"] = { "<Cmd>Refactor extract<CR>", "Extract" },
    ["<leader>rf"] = { "<Cmd>Refactor extract_to_file<CR>", "Extract block to file" },
    ["<leader>rv"] = { "<Cmd>Refactor extract_var<CR>", "Extract block to variable" },
    ["<leader>ri"] = { "<Cmd>Refactor inline_var<CR>", "Extrack block to inline variable" },
  },
  n = {
    ["<leader>ri"] = { "<Cmd>Refactor inline_var<CR>", "Extrack block to inline variable" },
    ["<leader>rb"] = { "<Cmd>Refactor extract_block<CR>", "Extrack block" },
    ["<leader>rbf"] = { "<Cmd>Refactor extract_block_to_file<CR>", "Extrack block to file" },
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
      "Repeat Prev Hunk",
    },
    ["]h"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local gs = require "gitsigns"
        local next_hunk, _ = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        return next_hunk()
      end,
      "Repeat Next Hunk",
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
      "Repeat Next Hunk",
    },
    ["[h"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local gs = require "gitsigns"
        local next_hunk, prev_hunk = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        return next_hunk(), prev_hunk()
      end,
      "Repeat Prev Hunk",
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
      "Repeat Next Hunk",
    },
    ["[h"] = {
      function()
        local ts_move = require "nvim-treesitter.textobjects.repeatable_move"
        local gs = require "gitsigns"
        local next_hunk, prev_hunk = ts_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
        return next_hunk(), prev_hunk()
      end,
      "Repeat Prev Hunk",
    },
  },
}

return M
