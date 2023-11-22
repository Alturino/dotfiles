---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  extended_integrations = { "dap", "notify", "todo", "trouble" },
  hl_add = highlights.add,
  hl_override = highlights.override,
  telescope = { style = "bordered" },
  theme = "catppuccin",
  theme_toggle = { "catppuccin", "one_light" },
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
