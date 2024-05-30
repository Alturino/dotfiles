local slow_format_filetypes = {}
return {
  {
    "stevearc/conform.nvim",
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    ft = { "sql" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format { lsp_fallback = true, async = true, timeout_ms = 1000 }
        end,
        desc = "Conform Format",
      },
    },
    opts = {
      lsp_fallback = true,
      formatters = {
        sqlfluff = {
          inherit = false,
          command = "sqlfluff",
          args = { "fix", "--disable-progress-bar", "-n", "-v" },
          stdin = false,
          require_cwd = false,
        },
      },
      formatters_by_ft = {
        sql = { "sqlfluff", "pg_format" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        if slow_format_filetypes[vim.bo[bufnr].filetype] then
          return
        end
        local function on_format(err)
          if err and err:match "timeout$" then
            slow_format_filetypes[vim.bo[bufnr].filetype] = true
          end
        end

        return { timeout_ms = 200, lsp_fallback = true }, on_format
      end,

      format_after_save = function(bufnr)
        if not slow_format_filetypes[vim.bo[bufnr].filetype] then
          return
        end
        return { lsp_fallback = true }
      end,
    },
    config = function(_, opts)
      local conform = require "conform"
      local util = require "conform.util"

      conform.setup(opts)
    end,
  },
}
