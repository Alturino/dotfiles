return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
  keys = function()
    return {
      { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Dadbod toggle" },
      { "<leader>da", "<cmd>DBUIAddConnection<CR>", desc = "Dadbod add connection" },
    }
  end,
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_bind_param_pattern = "\\$\\d\\+"
    vim.g.db_ui_execute_on_save = 0
    vim.g.db_ui_save_location = "./"
    vim.g.db_ui_show_database_icon = 1
    vim.g.db_ui_tmp_query_location = vim.g.db_ui_save_location .. "/queries/"
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1
  end,
}
