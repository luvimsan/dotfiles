vim.o.number = true
vim.o.relativenumber = true
vim.o.guicursor = ""
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.o.colorcolumn = "80"
vim.o.splitright = true
vim.o.splitbelow = true
vim.g.syntax = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.wrap = false
vim.o.confirm = true

-- Set backup
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- set search
vim.o.inccommand = "split"
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.conceallevel = 2

vim.o.termguicolors = true
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.o.updatetime = 50

-- vim fold
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable= true
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.o.list = true
vim.opt.listchars = {
  tab      = "» ",
  space    = "·",
  trail    = "•",
  extends  = "»",
  precedes = "«",
  nbsp     = "␣",
}

require("vim._core.ui2").enable()
