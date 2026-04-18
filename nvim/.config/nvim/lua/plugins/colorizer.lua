require("plugins.lazyload").on_vim_enter(function()
    vim.pack.add({
        "https://github.com/NvChad/nvim-colorizer.lua"
    })

    require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
            RGB = true,
            RRGGBB = true,
            names = true,
            css = true,
            css_fn = true,
            mode = "virtualtext",
        },
    })

end)


