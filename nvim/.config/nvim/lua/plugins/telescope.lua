return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = { "Marskey/telescope-sg" },
  keys = {},
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
