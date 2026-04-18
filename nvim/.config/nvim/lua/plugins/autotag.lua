require("plugins.lazyload").on_vim_enter(function()

    vim.pack.add ({
        "https://github.com/windwp/nvim-ts-autotag",
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "html",
        once = false,
        callback = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
            })
        end,
    })

end)

