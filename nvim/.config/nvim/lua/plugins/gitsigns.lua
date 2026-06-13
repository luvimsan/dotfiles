vim.pack.add({
    "https://github.com/lewis6991/gitsigns.nvim"
})

require('gitsigns').setup({
  signs = {
    add          = { text = '▕' },
    change       = { text = '▕' },
    delete       = { text = ' ' },
    topdelete    = { text = '▔' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
})

vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", {})
