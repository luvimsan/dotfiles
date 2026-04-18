vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
})

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "telescope-fzf-native.nvim" then
			vim.system({ "make"}, { cwd = ev.data.path })
		end
	end,
})


require("telescope").setup({
    defaults = require("telescope.themes").get_ivy({
        layout_config = {
            height = 0.40,
        },
        preview = false,
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "-uu",
        },
    }),
})
require("telescope").load_extension("fzf")

vim.keymap.set("n", "<leader>pf", function()
    require("telescope.builtin").find_files({ hidden = true })
end)
vim.keymap.set("n", "<leader>gh", function()
    require("telescope.builtin").help_tags()
end)
vim.keymap.set("n", "<C-p>", function()
    require("telescope.builtin").git_files()
end)
vim.keymap.set("n", "<leader>ch", function()
    require("telescope.builtin").command_history()
end)
vim.keymap.set("n", "<leader>to", function()
    require("telescope.builtin").buffers()
end)
vim.keymap.set("n", "<leader>ps", function()
    require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
end)

