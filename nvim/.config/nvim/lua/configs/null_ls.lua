local null_ls = require "null-ls"

local d = null_ls.builtins.diagnostics
local ca = null_ls.builtins.code_actions
local f = null_ls.builtins.formatting

local sources = {
  ca.gitsigns,
  ca.gomodifytags,
  ca.impl,
  ca.refactoring,

  d.actionlint,
  d.commitlint,
  d.gitlint,
  d.golangci_lint,
  d.hadolint,
  d.ktlint,
  d.revive,
  d.rubocop,
  d.sqlfluff,
  d.staticcheck,
  d.stylelint,
  d.textlint,
  d.tfsec,
  d.vint,

  f.clang_format.with { filetypes = { "c", "cpp" } },
  f.sqlfluff.with {
    args = {
      "fix",
      "--disable-progress-bar",
      "-n",
      "--stdin-filename",
      "$FILENAME",
      "-",
    },
  },
  f.dart_format,
  f.gofumpt,
  f.goimports,
  f.goimports_reviser,
  f.golines,
  f.google_java_format,
  f.ktlint,
  f.prettierd,
  f.rubocop,
  f.shellharden,
  f.stylua,
}

local vim = vim
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

return {
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format {
            bufnr = bufnr,
            filter = function(c)
              return c.name == "null-ls"
            end,
          }
        end,
      })
    end
  end,
}
