local M = {}

-- local codelldb_path = require("mason-registry").get_package("codelldb"):get_install_path()
-- local codelldb_executable = codelldb_path .. "/extension/adapter/codelldb"

local cpptools_path = require("mason-registry").get_package("cpptools"):get_install_path()
local cpptools_executable = cpptools_path .. "/extension/debugAdapters/bin/OpenDebugAD7"

local vscode_js_debug_path = require("mason-registry").get_package("js-debug-adapter"):get_install_path()
local vscode_js_debug_executable = vscode_js_debug_path .. "/src/dapDebugServer.js"

local node_debug2_adapter_path = require("mason-registry").get_package("node-debug2-adapter"):get_install_path()
local node_debug2_adapter_executable = node_debug2_adapter_path .. "/out/src/nodeDebug.js"

local firefox_debug_adapter_path = require("mason-registry").get_package("firefox-debug-adapter"):get_install_path()
local firefox_debug_adapter_executable = firefox_debug_adapter_path .. "/dist/adapter.bundle.js"

local dart_debug_adapter_path = require("mason-registry").get_package("dart-debug-adapter"):get_install_path()
local dart_debug_adapter_executable = dart_debug_adapter_path .. "/extension/out/dist/debug.js"

local go_debug_adapter_path = require("mason-registry").get_package("go-debug-adapter"):get_install_path()
local go_debug_adapter_executable = go_debug_adapter_path .. "/extension/dist/debugAdapter.js"

local delve_path = require("mason-registry").get_package("delve"):get_install_path()
local delve_executable = delve_path .. "/dlv"

M.adapters = {
  go = {
    type = "executable",
    command = "node",
    args = { go_debug_adapter_executable },
  },
  delve = {
    type = "server",
    port = "${port}",
    executable = {
      command = delve_executable,
      args = { "dap", "-l", "127.0.0.1:${port}" },
    },
  },
  cppdbg = {
    id = "cppdbg",
    type = "executable",
    command = cpptools_executable,
  },
  ["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "node",
      args = { vscode_js_debug_executable, "${port}" },
    },
  },
  node2 = {
    type = "executable",
    command = "node",
    args = { node_debug2_adapter_executable },
  },
  firefox = {
    type = "executable",
    command = "node",
    args = { firefox_debug_adapter_executable },
  },
  dart = {
    type = "executable",
    command = "node",
    args = { dart_debug_adapter_executable, "flutter" },
  },
  -- codelldb = {
  --   id = "codelldb",
  --   type = "server",
  --   port = "${port}",
  --   executable = {
  --     -- CHANGE THIS to your path!
  --     command = codelldb_executable,
  --     args = { "--port", "${port}" },
  --
  --     -- On windows you may have to uncomment this:
  --     -- detached = false,
  --   },
  -- },
}

M.configurations = {
  cpp = {
    {
      name = "Start debuggin with cpptools / cppdbg",
      type = "cppdbg",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopAtEntry = true,
      setupCommands = {
        {
          text = "-enable-pretty-printing",
          description = "enable pretty printing",
          ignoreFailures = false,
        },
      },
    },
    -- {
    --   name = "Start Debugging with codelldb",
    --   type = "codelldb",
    --   request = "launch",
    --   program = function()
    --     return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    --   end,
    --   cwd = "${workspaceFolder}",
    --   stopOnEntry = false,
    --   setupCommands = {
    --     {
    --       text = "-enable-pretty-printing",
    --       description = "enable pretty printing",
    --       ignoreFailures = false,
    --     },
    --   },
    -- },
  },
  go = {
    {
      type = "delve",
      name = "Launch debugger with delve",
      request = "launch",
      program = "${file}",
    },
    {
      type = "delve",
      name = "Launch debugger test with delve", -- configuration for debugging test files
      request = "launch",
      mode = "test",
      program = "${file}",
    },
    -- works with go.mod packages and sub packages
    {
      type = "delve",
      name = "Launch debugger test (go.mod) with delve",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}",
    },
    {
      type = "go",
      name = "Launch debugger test with vscode-go/go-debug-adapter",
      request = "launch",
      showLog = false,
      program = "${file}",
      dlvToolPath = vim.fn.exepath(delve_executable), -- Adjust to where delve is installed
    },
  },
  javascript = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch debugger with vscode-js-debug/pwa-node",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "node2",
      request = "launch",
      name = "Launch debugger with node_debug2_adapter/node2",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch debugger with vscode_js_debug/pwa-node with deno runtime",
      runtimeExecutable = "deno",
      runtimeArgs = {
        "run",
        "--inspect-wait",
        "--allow-all",
      },
      program = "${file}",
      cwd = "${workspaceFolder}",
      attachSimplePort = 9229,
    },
    {
      type = "firefox",
      request = "launch",
      name = "Launch debug with firefox",
      reAttach = true,
      url = "http://localhost:3000",
      webRoot = "${workspaceFolder}",
      firefoxExecutable = "/usr/bin/firefox",
    },
  },
  dart = {
    {
      type = "dart",
      request = "launch",
      name = "Launch flutter",
      dartSdkPath = os.getenv "HOME" .. "/flutter/bin/cache/dart-sdk/",
      flutterSdkPath = os.getenv "HOME" .. "/flutter",
      program = "${workspaceFolder}/lib/main.dart",
      cwd = "${workspaceFolder}",
    },
  },
}

return M
