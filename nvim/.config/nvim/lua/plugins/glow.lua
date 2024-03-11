return {
  {
    "ellisonleao/glow.nvim",
    event = "BufEnter *.md",
    opts = function()
      local glow = require("mason-registry").get_package("glow"):get_install_path() .. "/glow"
      return {
        glow_path = glow,
        install_path = glow,
        style = "dark",
        width = 120,
      }
    end,
    config = function(_, opts)
      require("glow").setup(opts)
    end,
    cmd = "Glow",
    keys = {
      { "<leader>pd", "<cmd>Glow<cr>", desc = "Preview Markdown", nowait = true, noremap = true },
    },
  },
}
