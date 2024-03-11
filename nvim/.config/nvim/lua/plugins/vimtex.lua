return {
  {
    "lervag/vimtex",
    event = "BufEnter *.tex",
    ft = { "tex" },
    cmd = {
      "VimtexInfo",
      "VimtexTocOpen",
      "VimtexTocToggle",
      "VimtexCompile",
      "VimtexStop",
      "VimtexClean",
    },
    config = function()
      local v = vim
      v.g.vimtex_compiler_method = "latexmk"
      v.g.vimtex_view_method = "zathura"
      v.g.vimtex_view_general_viewer = "zathura"
      v.g.maplocalleader = " "
    end,
  },
}
