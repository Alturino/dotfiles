return {
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      icons = {
        expanded = "▾",
        collapsed = "▸",
        current_frame = "*",
      },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    },
    config = function(_, opts)
      require("dapui").setup(opts)
    end,
  },
}
