local c = { "clang_format" }
local js = { "eslint_d", "prettierd" }
local slow_format_filetypes = {}
return {
  {
    "stevearc/conform.nvim",
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      lsp_fallback = true,
      formatters = {
        prisma = {
          command = "prisma",
          args = { "format", "$FILENAME" },
          stdin = false,
          require_cwd = false,
        },
        sqlfluff = {
          inherit = false,
          command = "sqlfluff",
          args = { "format", "--disable-progress-bar", "-n" },
          stdin = false,
          require_cwd = false,
        },
      },
      formatters_by_ft = {
        c = c,
        cpp = c,
        css = { "prettierd" },
        dart = { "dart_format" },
        go = { "gofumpt", "goimports", "goimports_reviser", "golines" },
        html = { "prettier" },
        java = { "google_java_format" },
        javascript = js,
        lua = { "stylua" },
        prisma = { "prismaFmt" },
        python = { "ruff_fix", "ruff_format" },
        ruby = { "rubocop" },
        sh = { "shfmt", "shellharden" },
        sql = { "sqlfluff", "pg_format" },
        typescript = js,
        xml = { "xmllint", "xmlformat" },
        yml = { "yamlfmt" },
      },
      format_on_save = function(bufnr)
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
