return {
    "MeanderingProgrammer/render-markdown.nvim",
    main = "render-markdown",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    config = function(_, opts)

        vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#32302f", fg = "#7493ad" })
        vim.api.nvim_set_hl(0, "RenderMarkdownH1",   { fg = "#7493ad", bold = true })

        vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#32302f", fg = "#8ec07c" })
        vim.api.nvim_set_hl(0, "RenderMarkdownH2",   { fg = "#8ec07c", bold = true })

        vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = "#32302f", fg = "#83a598" })
        vim.api.nvim_set_hl(0, "RenderMarkdownH3",   { fg = "#83a598", bold = true })

        vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { bg = "#32302f", fg = "#fe8019" })
        vim.api.nvim_set_hl(0, "RenderMarkdownH4",   { fg = "#fe8019", bold = true })

        vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { bg = "#32302f", fg = "#b16286" })
        vim.api.nvim_set_hl(0, "RenderMarkdownH5",   { fg = "#b16286", bold = true })

        vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { bg = "#32302f", fg = "#83a598" })
        vim.api.nvim_set_hl(0, "RenderMarkdownH6",   { fg = "#83a598", bold = true })

        vim.api.nvim_set_hl(0, "RenderMarkdownCode",       { bg = "#32302f"})
        vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = "#32302f", fg = "#e5c07b" })


        opts.pipe_table = {
            enabled = true,
            preset = "round",
        }

        require("render-markdown").setup(opts)
    end,
}
