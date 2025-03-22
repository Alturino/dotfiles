return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = { "Marskey/telescope-sg" },
  keys = {
    -- stylua: ignore start
    { "<leader>ff", LazyVim.pick("find_files", { root = false, hidden = true, no_ignore = true }), desc = "Find Files (cwd)" },
    { "<leader>fF", LazyVim.pick("find_files", { hidden = true, no_ignore = true }),               desc = "Find Files (Root Dir)" },
    { "<leader>fw", "<cmd>Telescope live_grep<cr>",                                                desc = "Grep (cwd)" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",                                                desc = "Help Pages" },
    { "<leader>fj", "<cmd>Telescope jumplist<cr>",                                                 desc = "Jump List" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>",                                                  desc = "Keymaps" },
    { '<leader>f"', "<cmd>Telescope registers<cr>",                                                desc = "Register" },
    { "<leader>fq", "<cmd>Telescope quickfix<cr>",                                                 desc = "Quickfix" },
    { "<leader>fs", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end,   desc = "Symbol", },
    { "<leader>fS", function() require("telescope.builtin").lsp_workspace_symbols() end,           desc = "Symbol", },
    { "<leader>fr", function() require("telescope.builtin").lsp_references() end,                  desc = "Find References", },
  },
  opts = {
    pickers = {
      find_files = {
        "rg",
        "-L",
        "--files",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "!.git",
        "--hidden",
      },
      hidden = true,
      no_ignore = true,
    },
    defaults = {
      vimgrep_arguments = {
        "rg",
        "-L",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
      },
      file_ignore_patterns = {
        ".git",
        "vendor",
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
      "ast_grep",
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
      ast_grep = {
        command = { "sg", "--json=stream" }, -- must have --json=stream
        grep_open_files = false, -- search in opened files
        lang = nil, -- string value, specify language for ast-grep `nil` for default
      },
    },
  },
}
