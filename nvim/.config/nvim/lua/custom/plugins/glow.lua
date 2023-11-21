return {
  {
    "ellisonleao/glow.nvim",
    event = "BufEnter *.md",
    config = function()
      require("glow").setup {
        style = "dark",
        width = 120,
      }
    end,
    cmd = "Glow",
  },
}
