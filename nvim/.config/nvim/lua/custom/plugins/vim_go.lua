return {
  {
    "fatih/vim-go",
    config = function()
      vim.keymap.set("n", "<leader>rn", "<cmd>GoRun<cr>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>ri", "<cmd>GoInstall<cr>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>rb", "<cmd>GoBuild<cr>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>rt", "<cmd>GoTest<cr>", { silent = true, noremap = true })
    end,
    cmd = {
      "GoBuild",
      "GoInstall",
      "GoTest",
      "GoTestFunc",
      "GoRun",
      "GoDebugStart",
      "GoDef",
      "GoDoc",
      "GoRename",
      "GoLint",
      "GoMetaLinter",
      "GoErrCheck",
    },
    event = "BufEnter *.go",
    build = ":GoUpdateBinaries",
    enabled = true,
    ft = { "go", "gomod", "gosum" },
  },
}
