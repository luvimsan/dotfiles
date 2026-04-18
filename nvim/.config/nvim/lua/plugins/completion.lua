require("plugins.lazyload").on_vim_enter(function()
    vim.pack.add({
        { src = "https://github.com/hrsh7th/nvim-cmp" },
        { src = "https://github.com/hrsh7th/cmp-buffer" },
        { src = "https://github.com/hrsh7th/cmp-path" },
        { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
        { src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2.*") },
        { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
        { src = "https://github.com/rafamadriz/friendly-snippets" },
        { src = "https://github.com/onsails/lspkind.nvim" },
        { src = "https://github.com/kristijanhusak/vim-dadbod-completion" },
    })

    vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
            if ev.data.spec.name == "LuaSnip" then
                vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path })
            end
        end,
    })

    local cmp_loaded = false
    local function setup_cmp()
        if cmp_loaded then
            return
        end
        cmp_loaded = true

        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        -- Lazy-load VSCode snippets on-demand
        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
            completion = { completeopt = "menu,menuone,preview,noselect" },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = {
                ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
                ["<C-e>"] = cmp.mapping.abort(),
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            formatting = {
                format = lspkind.cmp_format({ maxwidth = 50, ellipsis_char = "..." }),
            },
            sorting = {
                comparators = {
                    cmp.config.compare.offset,
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.locality,
                    cmp.config.compare.kind,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                },
            },
        })

        for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/custom/snippets/*.lua", true)) do
            loadfile(ft_path)()
        end

        vim.keymap.set({ "i", "s" }, "<c-k>", function()
            if luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            end
        end, { silent = true })

        vim.keymap.set({ "i", "s" }, "<c-j>", function()
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            end
        end, { silent = true })

        -- Setup vim-dadbod-completion only for SQL
        cmp.setup.filetype({ "sql" }, {
            sources = {
                { name = "vim-dadbod-completion" },
                { name = "buffer" },
            },
        })
    end

    -- Lazy load cmp when entering insert mode
    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = setup_cmp,
        once = true,
    })


end)
