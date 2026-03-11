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
                cpp = "g++ -std=c++23 -o %:r % && ./%:r",
                java = "javac % && java %:r",
                go = "go run %",
                rust = "cargo run",
            },
            bang_expansion = true,
            baleia_setup = true,
            error_regexp_table = {
                rust_location = {
                    regex = "^\\s*-->\\s*\\(.\\+\\):\\([1-9][0-9]*\\):\\([1-9][0-9]*\\)",
                    filename = 1,
                    row = 2,
                    col = 3,
                    priority = 2,
                }
            },
        }
    end,
}
