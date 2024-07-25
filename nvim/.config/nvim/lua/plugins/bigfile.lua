return {
  {
    "LunarVim/bigfile.nvim",
    lazy = false,
    opts = {
      filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
      pattern = { "txt", "log", "json" }, -- autocmd pattern or function see <### Overriding the detection of big files>
      features = { -- features to disable
        "indent_blankline",
        "illuminate",
        "lsp",
        "treesitter",
        "syntax",
        "matchparen",
        "vimopts",
        "filetype",
      },
    },
    config = function(_, opts)
      require("bigfile").setup(opts)
    end,
  },
}
