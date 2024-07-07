return {
  {
    "windwp/nvim-ts-autotag",
    ft = {
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
    opts = {
      opts = {
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
        skip_tags = {
          "area",
          "base",
          "br",
          "col",
          "command",
          "embed",
          "hr",
          "img",
          "slot",
          "input",
          "keygen",
          "link",
          "meta",
          "param",
          "source",
          "track",
          "wbr",
          "menuitem",
        },
      },
    },
    config = function(_, opts)
      require("nvim-ts-autotag").setup(opts)
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        virtual_text = {
          spacing = 5,
          min = vim.diagnostic.severity.WARN,
        },
        update_in_insert = true,
      })
    end,
  },
}
