local M = {}

M.ui = {
  theme = "catppuccin",
  transparency = false,
  telescope = { style = "bordered" },
  hl_override = {
    Comment = {
      italic = true,
    },
  },
  hl_add = {
    NvimTreeOpenedFolderName = { fg = "green", bold = true },
  },
  lsp = {
    signature = true,
    semantic_tokens = true,
  },
}

M.base46 = {
  integrations = {
    "blankline",
    "cmp",
    "codeactionmenu",
    "dap",
    "defaults",
    "devicons",
    "git",
    "hop",
    "lsp",
    "mason",
    "navic",
    "notify",
    "nvcheatsheet",
    "nvdash",
    "nvimtree",
    "rainbowdelimiters",
    -- "semantic_tokens",
    "statusline",
    "syntax",
    "tbline",
    "telescope",
    "todo",
    "treesitter",
    "trouble",
    "vim-illuminate",
    "whichkey",
  },
}

return M
