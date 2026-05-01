require("plugins.lazyload").on_vim_enter(function()

    vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
            if ev.data.spec.name == "nvim-treesitter" then
                vim.cmd("TSUpdate")
            end
        end,
    })

    vim.pack.add({
        { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }
    })

    require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath('data') .. '/site',
    })

    local parsers = {
        "make", "asm", "java", "markdown_inline", "latex", "python", "haskell",
        "css", "go", "bash", "sql", "html", "markdown", "ecma", "yaml", "commonlisp",
        "vimdoc", "html_tags", "jsx", "javascript", "lua", "vim", "cpp", "c",
    }

    for _, lang in ipairs(parsers) do
        local ok, err = pcall(function()
            require("nvim-treesitter").install({ lang }):wait(30000)
        end)
        if not ok then
            vim.notify("treesitter: failed to install " .. lang .. ": " .. tostring(err), vim.log.levels.WARN)
        end
    end

	local function install_parser(lang)
		local ok, parsers = pcall(require, "nvim-treesitter.parsers")
		if not ok or not parsers[lang] then
			return
		end
		vim.schedule(function()
			local choice = vim.fn.confirm(
				"No treesitter parser for '" .. lang .. "'. Install it?",
				"&Yes\n&No",
				2
			)
			if choice == 1 then
				require("nvim-treesitter").install({ lang })
			end
		end)
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
		callback = function(event)
			local bufnr = event.buf
			local ft = event.match
			if ft == "" then return end

			local lang = vim.treesitter.language.get_lang(ft)
			if not lang then return end

			local ok = pcall(vim.treesitter.start, bufnr, lang)
			if not ok then
				install_parser(lang)
			end
		end,
	})
end)
