local exclude = {
  "**/.git/*",
  "**/node_modules/*",
  "**/vendor/*",
  "**/dist/*",
  "**/build/*",
  "**/.yarn/cache/*",
  "**/.yarn/releases/*",
  "**/.pnpm-store/*",
  "**/.vim",
  "**/.package-lock.json",
}
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,
            ignored = true,
            exclude = exclude,
          },
        },
      },
      explorer = {},
      scroll = { enabled = false },
      dashboard = { enabled = false },
    },
    keys = {
      -- Top Pickers & Explorer
      -- stylua: ignore start
      { "<leader>fw", function() Snacks.picker.grep({ hidden = true, ignored = false, exclude = exclude, }) end, desc = "Grep", },
      { "<leader>fh", function() Snacks.picker.help() end,                                                       desc = "Help Pages", },
      { "<leader>fj", function() Snacks.picker.jumps() end,                                                      desc = "Jumps", },
      { "<leader>fk", function() Snacks.picker.keymaps() end,                                                    desc = "Keymaps", },
      { '<leader>f"', function() Snacks.picker.registers() end,                                                  desc = "Registers", },
      { "<leader>fq", function() Snacks.picker.qflist() end,                                                     desc = "Quickfix List", },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end,                                                desc = "LSP Symbols", },
      { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end,                                      desc = "LSP Workspace Symbols", },
      { "<leader>ss", mode = { 'n', 'x', },                                                                      false },
      { "<leader>fr", function() Snacks.picker.lsp_references() end,                                             nowait = true,                  desc = "References", },
    },
  },
}
