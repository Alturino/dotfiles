return {
  {
    "rmagatti/goto-preview",
    opts = {},
    keys = {
      {
        "gpd",
        function()
          require("goto-preview").goto_preview_definition()
        end,
        desc = "Goto Preview definition",
        silent = true,
        noremap = true,
      },
      {
        "gpt",
        function()
          require("goto-preview").goto_preview_type_definition()
        end,
        desc = "Goto Preview type_definition",
        silent = true,
        noremap = true,
      },
      {
        "gpi",
        function()
          require("goto-preview").goto_preview_implementation()
        end,
        desc = "Goto Preview implementation",
        silent = true,
        noremap = true,
      },
      {
        "gpD",
        function()
          require("goto-preview").goto_preview_declaration()
        end,
        desc = "Goto Preview delcaration",
        silent = true,
        noremap = true,
      },
      {
        "gpx",
        function()
          require("goto-preview").close_all_win()
        end,
        desc = "Goto Preview close_all_win",
        silent = true,
        noremap = true,
      },
      {
        "gpr",
        function()
          require("goto-preview").goto_preview_references()
        end,
        desc = "Goto Preview preview_references",
        silent = true,
        noremap = true,
      },
      {
        "gp",
        function()
          require("goto-preview").close_all_win()
        end,
        desc = "Goto Preview close_all_win",
        silent = true,
        noremap = true,
      },
    },
    config = function(_, opts)
      require("goto-preview").setup(opts)
    end,
  },
}
