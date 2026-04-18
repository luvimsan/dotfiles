local dev = require("config.dev")

vim.pack.add({
    { src = dev.prefer_local("~/plugins/foo.nvim", "https://github.com/luvimsan/foo.nvim")}
})
