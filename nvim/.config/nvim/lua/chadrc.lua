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
  }
}

M.base46 = {
  integrations = {
    "blankline",
    "cmp",
    "dap",
    "defaults",
    "devicons",
    "git",
    "lsp",
    "mason",
    "notify",
    "nvcheatsheet",
    "nvdash",
    "nvimtree",
    "statusline",
    "syntax",
    "tbline",
    "telescope",
    "todo",
    "treesitter",
    "trouble",
    "whichkey",
  }
}

return M
