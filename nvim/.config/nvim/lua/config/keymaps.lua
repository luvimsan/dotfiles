-- improvements
vim.keymap.set({ "n", "i" }, "<C-b>", "<Esc>:t.<CR>", { silent = false })

-- commands
vim.keymap.set("n", "<localleader>h", ":Compile<CR>")
vim.keymap.set("n", "<leader>pv", vim.cmd.Oil)
vim.keymap.set("n", "<leader>sa", vim.cmd.DBUIToggle)
vim.keymap.set("n", "<M-a>", "ggVG")
vim.keymap.set("n", "]]", ":cnext<CR>zz", { noremap = true, silent = true })
vim.keymap.set("n", "[[", ":cprev<CR>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>")

-- Navigation
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
vim.keymap.set("i", "<M-l>", "<Right>")
vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>")

for i = 1, 9 do
  vim.keymap.set({"n", "i"}, "<A-" .. i .. ">", "<Cmd>" .. i .. "tabnext<CR>")
end

-- g remap
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

--split window
vim.keymap.set("n", "<leader>sv", "<C-w>v")
vim.keymap.set("n", "<leader>sh", "<C-w>s")

-- tabs
vim.keymap.set("n", "<leader>.", ":+tabmove<CR>", { silent = true })
vim.keymap.set("n", "<leader>,", ":-tabmove<CR>", { silent = true })

-- windows navigation
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-h>", "<C-w>h")

-- control the size of splits
vim.keymap.set("n", "<M-.>", "<C-w>5>")
vim.keymap.set("n", "<M-,>", "<C-w>5<")
vim.keymap.set("n", "<M-c>", "<C-w>+")
vim.keymap.set("n", "<M-r>", "<C-w>-")

-- Prevent 'x' from copying deleted characters to the clipboard
vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true })
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww ts<CR>")

-- remove idiotic keys
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "q:", "<Nop>")
vim.keymap.set("ca", "Q", "q")

-- prime prime
vim.keymap.set("n", "<leader>sn", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- run lua inline
vim.keymap.set("v", "<leader>l", ":lua<CR>")
vim.keymap.set("n", "<leader>l", "<cmd>.lua<CR>")
vim.keymap.set("n", "<leader><leader>l", ":silent w<CR>|:source %<CR>", {silent = true})

vim.keymap.set("n", "<leader>d", function()
    if vim.bo.filetype == "oil" then
        vim.cmd("lcd " .. vim.fn.fnameescape(require("oil").get_current_dir()))
    elseif vim.fn.expand("%:p:h") ~= "" then
        vim.cmd("lcd " .. vim.fn.fnameescape(vim.fn.expand("%:p:h")))
    end
end)

vim.keymap.set("n", "<leader>m", function()
    local winids = vim.api.nvim_list_wins()
    for _, id in ipairs(winids) do
        local bufnr = vim.api.nvim_win_get_buf(id)
        if vim.api.nvim_buf_get_name(bufnr):match("oil://") then
            vim.api.nvim_win_close(id, false)
            return
        end
    end
    vim.cmd("sp")
    vim.cmd("Oil")
end)

-- toggle fugitive
local function toggle_fugitive()
    local winids = vim.api.nvim_list_wins()
    for _, id in ipairs(winids) do
        local bufnr = vim.api.nvim_win_get_buf(id)
        if vim.api.nvim_buf_get_name(bufnr):match("fugitive://") then
            vim.api.nvim_win_close(id, false)
            return
        end
    end
    vim.cmd("Git")
end

vim.keymap.set("n", "<leader>gs", toggle_fugitive)

--quickfix
vim.keymap.set("n", "<leader>q", function()
    if vim.fn.getqflist({ winid = 0 }).winid > 0 then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end)

-- gx and gX for browsing and copying links
local function extract_url(line)
    return line:match("(https?://[%w-_%.%?%.:/%+=&]+)")
end
vim.keymap.set("v", "gX", function()
    local text
    vim.cmd('normal! "vy')
    text = vim.fn.getreg('v')

    local url = extract_url(text)
    if url then
        os.execute("$BROWSER " .. url:gsub(" ", "\\ ") .. " >/dev/null 2>&1")
        os.execute("xdotool key super+1")
    else
        print("No URL found")
    end
end, {})
vim.keymap.set("v", "gx", function()
    local text
    vim.cmd('normal! "vy')
    text = vim.fn.getreg('v')

    local url = extract_url(text)
    if url then
        vim.fn.setreg('+', url)
        print("Copied: " .. url)
    else
        print("No URL found")
    end
end, {})

-- copy the current path to clipboard
vim.keymap.set("n", "<leader>yp", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    print("File path copied: " .. path)
end)
