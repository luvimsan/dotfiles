vim.pack.add ({
    "https://github.com/blazkowolf/gruber-darker.nvim",
})

vim.cmd.colorscheme("gruber-darker")
vim.api.nvim_set_hl(0, "Whitespace", { fg = "#3a3a3a" })
vim.api.nvim_set_hl(0, "OilWinBar", { fg = "#9a9a9a" })
vim.api.nvim_set_hl(0, "OilWinBarNC", { fg = "#9a9a9a" })

