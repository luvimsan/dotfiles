require("plugins.lazyload").on_vim_enter(function()
    vim.pack.add ({
        "https://github.com/folke/snacks.nvim",
    })

    require("snacks").setup({
        bigfile = { enabled = true },
    })

end)

