require("plugins.lazyload").on_vim_enter(function()
    vim.pack.add({
        "https://github.com/nvim-lua/plenary.nvim",
        "https://github.com/m00qek/baleia.nvim",
        "https://github.com/ej-shafran/compile-mode.nvim"
    })
    vim.g.compile_mode = {
        default_command = {
            python = "python %",
            lua = "lua %",
            javascript = "node %",
            typescript = "node %",
            c = "gcc -g -o %:r % && ./%:r",
            cpp = "g++ -g -std=c++23 -o %:r % && ./%:r",
            java = "javac % && java %:r",
            go = "go run %",
            rust = "cargo run",
            tex = "latexmk -pdf -pdflatex='pdflatex -interaction=nonstopmode -synctex=-1' %:r.tex",
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
            },
        },
    }
end)
