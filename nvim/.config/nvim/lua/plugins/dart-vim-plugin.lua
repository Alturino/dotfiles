return {
  {
    "dart-lang/dart-vim-plugin",
    ft = { "dart" },
    event = "BufEnter *.dart",
    init = function()
      vim.g.dart_format_on_save = true
      vim.g.dart_html_in_string = true
      vim.g.dart_style_guid = 2
      vim.g.dart_trailing_comma_indent = true
    end,
  },
}
