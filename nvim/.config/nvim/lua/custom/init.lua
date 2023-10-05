local autocmd = vim.api.nvim_create_autocmd

local vim = vim
local g = vim.g
local opt = vim.opt
local clipboard = opt.clipboard

vim.scriptencoding = "utf-8"

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false
opt.foldlevelstart = 99
opt.foldlevel = 99
opt.autowrite = true
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.number = true
opt.smartcase = true
opt.relativenumber = true
opt.ignorecase = true
opt.ruler = true
opt.wrap = false
opt.lazyredraw = true

opt.title = true
opt.autoindent = true
opt.smartindent = true
opt.breakindent = true
opt.smarttab = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.hlsearch = true
opt.backup = false
opt.showcmd = true
opt.cmdheight = 1
opt.termguicolors = true
g.vscode_snippets_path = "./snippets/vscode/"
g.lua_snippets_path = "./snippets/lua/"
g.dart_html_in_string = true
g.dart_style_guid = 2
g.dart_format_on_save = true
g.dart_trailing_comma_indent = true

-- Auto resize panes when resizing nvim window
autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})

autocmd("FileType", {
  pattern = "*.go",
  callback = function()
    vim.schedule(function()
      opt.shiftwidth = 4
      opt.tabstop = 4
      opt.expandtab = false
    end)
  end,
})

autocmd("FileType", {
  pattern = { "*.java", "*.kotlin", "*.python" },
  callback = function()
    vim.schedule(function()
      opt.shiftwidth = 4
      opt.tabstop = 4
      opt.expandtab = true
    end)
  end,
})

local has = vim.fn.has
local is_win = has "win32" == 1
local is_mac = has "macunix" == 1
local is_wsl = has "wsl" == 1
local is_linux = has "linux" == 1

-- if is_win then
--  clipboard:preprend { "unnamed", "unnamedplus" }
--  opt.shell = "pwsh.exe"
--  opt.shellcmdflag =
--    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
--  opt.shellxquote = ""
--  opt.shellquote = ""
--  opt.shellredir = ""
--  opt.shellpipe = ""
-- end

if is_wsl then
  vim.cmd [[
    augroup Yank
    autocmd!
    autocmd TextYankPost * :call system('/mnt/c/windows/system32/clip.exe ',@")
    augroup END
  ]]
end

if is_mac or is_linux then
  clipboard:append { "unnamedplus" }
end
