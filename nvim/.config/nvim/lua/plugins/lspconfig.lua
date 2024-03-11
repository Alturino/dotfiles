return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"jose-elias-alvarez/null-ls.nvim",
				opts = function()
					return require("configs.null_ls")
				end,
				config = function(_, opts)
					require("null-ls").setup(opts)
				end,
			},
			{ "b0o/schemastore.nvim" },
		},
		config = function()
			require("nvchad.configs.lspconfig").defaults()
			require("configs.lspconfig")
		end, -- Override to setup mason-lspconfig
	},
}
