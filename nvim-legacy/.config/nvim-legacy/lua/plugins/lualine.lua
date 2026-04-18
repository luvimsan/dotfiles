return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",


    config = function()

        local function cwd()
            return vim.fn.fnamemodify(vim.fn.getcwd(0), ":~")
        end
        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = "gruvbox-material",
            },
            sections = {
                lualine_a = {
                    { "mode" },
                },

                lualine_c = {
                    { cwd },
                },
            },
        })
    end,
}
