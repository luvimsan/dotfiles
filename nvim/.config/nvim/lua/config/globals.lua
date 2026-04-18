P = function(v)
    print(vim.inspect(v))
    return v
end

function load_plugins()
    local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
    for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
        if file:match("%.lua$") then
            require("plugins." .. file:gsub("%.lua$", ""))
        end
    end
end
