local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local f = null_ls.builtins.formatting
local d = null_ls.builtins.diagnostics
local ca = null_ls.builtins.code_actions

local sources = {
  f.autoflake,
  f.autopep8,
  f.black,
  f.clang_format.with {
    filetypes = { "c", "cpp" },
  },
  f.gofumpt,
  f.goimports,
  f.goimports_reviser,
  f.golines,
  f.isort,
  f.ktlint,
  f.latexindent,
  f.prettierd,
  f.shellharden,
  f.sqlfmt,
  f.stylua,
  f.standardts,
  f.xmlformat,
  f.yamlfmt,
  f.rubocop,
  f.google_java_format,
  f.eslint_d,

  d.actionlint,
  d.commitlint,
  d.cpplint,
  d.eslint_d,
  d.flake8,
  d.gitlint,
  d.golangci_lint,
  d.hadolint,
  d.jsonlint,
  d.ktlint,
  d.luacheck,
  d.mypy,
  d.pydocstyle,
  d.pylama,
  d.pylint.with {
    diagnostics_postprocess = function(diagnostic)
      diagnostic.code = diagnostic.message_id
    end,
  },
  d.revive,
  d.rubocop,
  d.shellcheck,
  d.sqlfluff,
  d.staticcheck,
  d.stylelint,
  d.textlint,
  d.tfsec,
  d.vint,
  d.yamllint,

  ca.gomodifytags,
  ca.gitsigns,
  ca.refactoring,
  ca.eslint_d,
  ca.impl,
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
