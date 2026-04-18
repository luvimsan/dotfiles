require("plugins.lazyload").on_vim_enter(function()
    vim.pack.add({
        "https://github.com/neovim/nvim-lspconfig",
        "https://github.com/folke/lazydev.nvim",
        "https://github.com/williamboman/mason.nvim",
        "https://github.com/williamboman/mason-lspconfig.nvim",
        "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        "https://github.com/b0o/SchemaStore.nvim",
    })

    -- lazydev for lua
    require("lazydev").setup()

    local servers = {
        rust_analyzer = true,
        pyright = true,
        ruff = { manual_install = true },
        bashls = true,
		jdtls = true,
        gopls = {
            manual_install = true,
            settings = {
                gopls = {
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                },
            },
        },
        ts_ls = true,
        html = true,
        cssls = {
            server_capabilities = {
                documentFormattingProvider = false,
            },
        },
        clangd = {
            init_options = { clangdFileStatus = true },
            filetypes = { "c", "cpp" },
        },
    }

    local servers_to_install = vim.tbl_filter(function(key)
        local t = servers[key]
        if type(t) == "table" then
            return not t.manual_install
        else
            return t
        end
    end, vim.tbl_keys(servers))

    require("mason").setup()

    local ensure_installed = {
        "rust_analyzer",
		"ruff",
		"bashls",
		"pyright",
		"gopls",
		"ts_ls",
		"jdtls",
        "clangd",
        "lua_ls",
        "stylua",
        "delve",
        "html",
        "cssls",
        "marksman",
    }

    vim.list_extend(ensure_installed, servers_to_install)
    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    vim.lsp.config("*", {
        capabilities = vim.lsp.protocol.make_client_capabilities(),
    })

    for name, config in pairs(servers) do
        if config == true then
            config = {}
        end

        if next(config) ~= nil then
            local lsp_config = vim.tbl_deep_extend("force", {}, config)
            lsp_config.manual_install = nil
            vim.lsp.config(name, lsp_config)
        end

        vim.lsp.enable(name)
    end

    local disable_semantic_tokens = {
        lua = true,
    }

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local bufnr = args.buf
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

            local settings = servers[client.name]
            if type(settings) ~= "table" then
                settings = {}
            end

            vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })

            local filetype = vim.bo[bufnr].filetype
            if disable_semantic_tokens[filetype] then
                client.server_capabilities.semanticTokensProvider = nil
            end

            if settings.server_capabilities then
                for k, v in pairs(settings.server_capabilities) do
                    if v == vim.NIL then v = nil end
                    client.server_capabilities[k] = v
                end
            end
        end,
    })

    require("lsp_lines").setup()
    vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
end)
