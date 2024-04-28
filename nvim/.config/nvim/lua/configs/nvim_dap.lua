local dap = require "dap"
local dapui = require "dapui"
local dap = require "configs.dap"

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

dap.adapters = dap.adapters
dap.configurations = dap.configurations
