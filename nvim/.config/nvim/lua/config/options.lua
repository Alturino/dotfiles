-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local vim = vim
local g = vim.g

local opt = vim.opt
local clipboard = opt.clipboard

vim.scriptencoding = "utf-8"

opt.autowrite = true
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.foldenable = false
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
opt.ignorecase = true
opt.lazyredraw = false
opt.number = true
opt.relativenumber = true
opt.ruler = true
opt.smartcase = true
opt.wrap = false

-- Dart plugin
g.dart_format_on_save = true
g.dart_html_in_string = true
g.dart_style_guid = 2
g.dart_trailing_comma_indent = true

g.lua_snippets_path = "./snippets/lua/"
g.vscode_snippets_path = "./snippets/vscode/"

-- Dadbod
g.db_ui_bind_param_pattern = "\\$\\d\\+"
g.db_ui_execute_on_save = 0
g.db_ui_save_location = "~/.local/share/db_ui"
g.db_ui_tmp_query_location = g.db_ui_save_location .. "/queries/"
g.db_ui_use_nerd_fonts = 1
g.db_ui_use_nvim_notify = 1

opt.autoindent = true
opt.backup = false
opt.breakindent = true
opt.cmdheight = 1
opt.expandtab = true
opt.hlsearch = true
opt.shiftwidth = 2
opt.showcmd = true
opt.smartindent = true
opt.smarttab = true
opt.tabstop = 2
opt.termguicolors = true
opt.title = true

vim.filetype.add({
  pattern = {
    ["docker.*%.ya?ml"] = "yaml.docker-compose",
    [".*compose%.ya?ml"] = "yaml.docker-compose",
  },
})

local has = vim.fn.has
local is_win = has("win32") == 1
local is_mac = has("macunix") == 1
local is_wsl = has("wsl") == 1
local is_linux = has("linux") == 1

if is_win then
  clipboard:prepend({ "unnamed", "unnamedplus" })
  opt.shell = "pwsh.exe"
  opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  opt.shellxquote = ""
  opt.shellquote = ""
  opt.shellredir = ""
  opt.shellpipe = ""
end

if is_wsl then
  vim.cmd([[
    augroup Yank
    autocmd!
    autocmd TextYankPost * :call system('/mnt/c/windows/system32/clip.exe ',@")
    augroup END
  ]])
end

if is_mac or is_linux then
  clipboard:append({ "unnamedplus" })
end
