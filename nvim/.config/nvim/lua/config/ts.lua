local telescope = require("telescope")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local search_paths = vim.env.TS_SEARCH_PATHS
if not search_paths then
  search_paths = {
    vim.fn.expand("~"),
    vim.fn.expand("~/projects"),
    vim.fn.expand("~/personal"),
    vim.fn.expand("~/Downloads"),
    vim.fn.expand("~/dotfiles"),
    vim.fn.expand("~/dotfiles/suckless"),
    vim.fn.expand("~/tools"),
    vim.fn.expand("~/personal/courses"),
    "/media/fun/_loaay_data/2. 2_level_sem2",
    "/media/fun/_loaay_data/",
  }
end

local function telescope_dirs_to_oil()
  require("telescope.builtin").find_files({
    prompt_title = "Session paths",
    search_dirs = search_paths,
    find_command = { "fd", "--type", "d", "--max-depth", "1", "--hidden", "--exclude", ".git" },
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry and entry.path then
          vim.cmd.cd(entry.path)
          require("oil").open(entry.path)
        end
      end)
      map("n", "<CR>", function(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry and entry.path then
          vim.cmd.cd(entry.path)
          require("oil").open(entry.path)
        end
      end)
      return true
    end,
  })
end

vim.keymap.set("n", "<leader>ts", telescope_dirs_to_oil)

