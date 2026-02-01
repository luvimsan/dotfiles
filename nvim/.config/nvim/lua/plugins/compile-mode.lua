return {
    "ej-shafran/compile-mode.nvim",
    version = "^5.0.0",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "m00qek/baleia.nvim",
    },
    config = function()

        vim.g.compile_mode = {
            default_command = {
                python = "python %",
                lua = "lua %",
                javascript = "node %",
                typescript = "node %",
                c = "cc -o %:r % && ./%:r",
                cpp = "cc -std=c++23 -o %:r % && ./%:r",
                java = "javac % && java %:r",
                go = "go run %",
            },
            bang_expansion = true,
            baleia_setup = true,
        }
    end,
}
