local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local f = null_ls.builtins.formatting
local d = null_ls.builtins.diagnostics
local ca = null_ls.builtins.code_actions

local sources = {
  f.clang_format.with {
    filetypes = { "c", "cpp" },
  },
  f.dart_format,
  f.eslint_d,
  f.gofumpt,
  f.goimports,
  f.goimports_reviser,
  f.golines,
  f.google_java_format,
  f.ktlint,
  f.latexindent,
  f.prettierd,
  f.rubocop,
  f.ruff,
  f.shellharden,
  f.sqlfmt,
  f.standardts,
  f.stylua,
  f.xmlformat,
  f.yamlfmt,

  d.actionlint,
  d.commitlint,
  d.cpplint,
  d.eslint_d,
  d.gitlint,
  d.golangci_lint,
  d.hadolint,
  d.jsonlint,
  d.ktlint,
  d.luacheck,
  d.revive,
  d.rubocop,
  d.ruff,
  d.shellcheck,
  d.sqlfluff,
  d.staticcheck,
  d.stylelint,
  d.textlint,
  d.tfsec,
  d.vint,
  d.yamllint,

  ca.eslint_d,
  ca.gitsigns,
  ca.gomodifytags,
  ca.impl,
  ca.refactoring,
}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup {
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
            async = true,
          }
        end,
      })
    end
  end,
}
