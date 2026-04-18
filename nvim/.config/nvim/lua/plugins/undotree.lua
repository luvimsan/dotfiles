require("plugins.lazyload").on_vim_enter(function()
    vim.pack.add ({
        "https://github.com/mbbill/undotree",
    })

    vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
end)

