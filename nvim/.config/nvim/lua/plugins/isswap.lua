return {
    -- swap arguments and things
    "mizlan/iswap.nvim",
    keys = {
        { "gw",         ":ISwapWithRight<cr>", desc = "Swap two arguments" },
        { "<leader>is", ":ISwap<cr>",          desc = "Swap many arguments" },
    },
    opts = {
        keys = "arstdhneio",
    },
}
