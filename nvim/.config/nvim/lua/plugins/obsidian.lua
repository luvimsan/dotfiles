return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,

    keys = {
        { "<leader>on", ":ObsidianToday<CR>" },
        {
            "<leader>hn",
            function()
                local title = vim.fn.input("Note title: ")
                if title and title ~= "" then
                    vim.cmd("ObsidianNew " .. title)
                    vim.defer_fn(function()
                        vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, {})
                        vim.cmd("ObsidianTemplate 1. Full note.md")
                        vim.cmd("silent write")
                        vim.cmd("e!")
                        vim.api.nvim_win_set_cursor(0, { 2, 0 })
                    end, 100)
                end
            end,
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        disable_frontmatter = true,
        workspaces = {
            {
                name = "personal",
                path = "~/vault",
            },
        },
        -- Optional, if you keep notes in a specific subdirectory of your vault.
        notes_subdir = "2 - Source Materials",
        new_note_location = "notes_subdir",

        templates = {
            folder = "5 - Templates",
        },

        daily_notes = {
            folder = "6 - Journals/Daily",
            template = nil,
        },
        completion = {
            -- Set to false to disable completion.
            nvim_cmp = true,
            -- Trigger completion at 2 chars.
            min_chars = 2,
        },
        ui = {
            enable = false,
            checkboxes = {
                [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                ["x"] = { char = "", hl_group = "ObsidianDone" },
            },
        },
        note_id_func = function(title)
            return title
        end,
    },
    config = function(_, opts)
        require("obsidian").setup(opts)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function()
                if vim.fn.expand("%:p"):find(vim.fn.expand("~/vault")) then
                    vim.keymap.set("n", "<leader>pf", ":ObsidianQuickSwitch<CR>", { buffer = true, silent = true })
                    vim.keymap.set("n", "<leader>hi", ":ObsidianTemplate<CR>", { buffer = true, silent = true })
                end
            end,
        })
    end,
}
