return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		cmd = "Telescope",
		keys = {
			{
				"<leader>pf",
				function()
					require("telescope.builtin").find_files({ hidden = true })
				end,
			},
			{
				"<leader>gh",
				function()
					require("telescope.builtin").help_tags()
				end,
			},
			{
				"<C-p>",
				function()
					require("telescope.builtin").git_files()
				end,
			},
			{
				"<leader>ch",
				function()
					require("telescope.builtin").command_history()
				end,
			},
			{
				"<leader>to",
				function()
					require("telescope.builtin").buffers()
				end,
			},
			{
				"<leader>ps",
				function()
					require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
				end,
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = require("telescope.themes").get_ivy({
					layout_config = {
						height = 0.30,
					},
					preview = false,
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"-uu",
					},
				}),
			})

			telescope.load_extension("fzf")
		end,
	},
}
