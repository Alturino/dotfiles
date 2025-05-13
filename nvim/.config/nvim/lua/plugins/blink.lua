return {
  "saghen/blink.cmp",
  optional = true,
  dependencies = { "codeium.nvim", "saghen/blink.compat", "giuxtaposition/blink-cmp-copilot", "supermaven-nvim" },
  opts = {
    sources = {
      compat = { "codeium", "supermaven" },
      providers = {
        codeium = {
          kind = "Codeium",
          score_offset = 2,
          async = true,
        },
        supermaven = {
          kind = "Supermaven",
          score_offset = 1,
          async = true,
        },
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          kind = "Copilot",
          score_offset = 0,
          async = true,
        },
      },
    },
  },
}
