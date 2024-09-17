return {
  {
    "nvimtools/none-ls.nvim",
    opts = function()
      local null_ls = require("null-ls")

      local d = null_ls.builtins.diagnostics
      local ca = null_ls.builtins.code_actions
      local f = null_ls.builtins.formatting

      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

      return {
        debug = false,
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  async = true,
                  bufnr = bufnr,
                  filter = function(c)
                    return c.name == "null-ls"
                  end,
                })
              end,
            })
          end
        end,
        sources = {
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
          d.mypy,
          d.revive,
          d.rubocop,
          d.sqlfluff,
          d.staticcheck,
          d.stylelint,
          d.textlint,
          d.tfsec,
          d.vint,

          f.clang_format.with({ filetypes = { "c", "cpp" } }),
          f.sqlfluff.with({
            args = {
              "fix",
              "--disable-progress-bar",
              "-n",
              "--stdin-filename",
              "$FILENAME",
              "-",
            },
          }),
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
        },
      }
    end,
  },
}
