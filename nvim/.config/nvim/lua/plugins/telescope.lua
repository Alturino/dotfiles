return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- stylua: ignore start
    { "<leader>ff", LazyVim.pick("auto", { root = false }),                                      desc = "Find Files (cwd)" },
    { "<leader>fF", LazyVim.pick("auto"),                                                        desc = "Find Files (Root Dir)" },
    { "<leader>fw", "<cmd>Telescope live_grep<cr>",                                              desc = "Grep (cwd)" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",                                              desc = "Help Pages" },
    { "<leader>fj", "<cmd>Telescope jumplist<cr>",                                               desc = "Jump List" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>",                                                desc = "Keymaps" },
    { '<leader>f"', "<cmd>Telescope registers<cr>",                                              desc = "Register" },
    { "<leader>fq", "<cmd>Telescope quickfix<cr>",                                               desc = "Quickfix" },
    { "<leader>fs", function() require("telescope.builtin").lsp_workspace_symbols() end,         desc = "Symbol", },
    { "<leader>fS", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, desc = "Symbol", },
    { "<leader>fr", function() require("telescope.builtin").lsp_references() end,                desc = "Find References", },
  },
  opts = {
    defaults = {
      file_ignore_patterns = {
        "node_modules",
        "build",
        "dist",
      },
    },
    extensions_list = {
      "fzf",
      "notify",
      "refactoring",
      "terms",
      "themes",
      "harpoon",
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
  },
}
