local dap = require "dap"
local dapui = require "dapui"
local dap_adapters = require("configs.dap").adapters
local dap_configurations = require("configs.dap").configurations

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

dap.adapters = dap_adapters
dap.configurations = dap_configurations
