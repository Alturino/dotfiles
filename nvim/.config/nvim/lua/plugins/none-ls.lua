return {
  {
    "nvimtools/none-ls.nvim",
    opts = function()
      local null_ls = require("null-ls")

      local d = null_ls.builtins.diagnostics
      local ca = null_ls.builtins.code_actions
      local f = null_ls.builtins.formatting

      return {
        debug = false,
        sources = {
          ca.gitsigns,
          ca.gomodifytags,
          ca.impl,
          ca.refactoring,

          d.actionlint,
          d.commitlint,
          d.gitlint,
          d.hadolint,
          d.ktlint,
          d.mypy,
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
          -- f.google_java_format,
          f.ktlint,
          f.prettierd.with({
            disabled_filetypes = { "html", "css" },
          }),
          f.rubocop,
          f.shellharden,
          f.stylua,
        },
      }
    end,
  },
}
