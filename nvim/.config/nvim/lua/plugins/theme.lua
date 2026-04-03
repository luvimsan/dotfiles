return {
	{
		"ellisonleao/gruvbox.nvim",
		enabled = false,
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				transparent = false,
				transparent_mode = false,
				terminal_colors = true,
				undercurl = true,
				underline = true,
				bold = true,
				italic = {
					operators = false,
				},
				contrast = "hard",
				dim_inactive = false,
				overrides = {
					SignColumn = { bg = "none" },
					LineNr = { bg = "none" },
					CursorLineNr = { bg = "none" },
					VertSplit = { bg = "none", fg = "#3c3836" },
					NormalNC = { bg = "none" },
					NormalFloat = { bg = "none" },
					FloatBorder = { bg = "none" },
					Folded = { bg = "none" },
				},
			})
			vim.o.background = "dark"
			vim.cmd.colorscheme("gruvbox")
		end,
	},

	{
		"blazkowolf/gruber-darker.nvim",
		-- enabled = false,
		priority = 1000,
		config = function()
			require("gruber-darker").setup({
				bold = true,
				undercurl = true,
				underline = false,
				italic = { operators = false },
				dim_inactive = false,
				overrides = {
					SignColumn = { bg = "none" },
					LineNr = { bg = "none" },
					-- CursorLineNr = { bg = "none" },
					-- VertSplit = { bg = "none", fg = "#3c3836" },
					NormalNC = { bg = "none" },
					NormalFloat = { bg = "none" },
					FloatBorder = { bg = "none" },
					Folded = { bg = "none" },
				},
			})
		end,
	},
}
