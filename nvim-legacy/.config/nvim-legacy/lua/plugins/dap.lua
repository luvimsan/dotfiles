return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"leoluz/nvim-dap-go",
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
		"nvim-neotest/nvim-nio",
		"williamboman/mason.nvim",
	},
	config = function()
		local dap = require("dap")
		local ui = require("dapui")

		require("dapui").setup()
		require("dap-go").setup()

		require("nvim-dap-virtual-text").setup({
			-- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
			display_callback = function(variable)
				local name = string.lower(variable.name)
				local value = string.lower(variable.value)
				if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
					return "*****"
				end

				if #variable.value > 15 then
					return " " .. string.sub(variable.value, 1, 15) .. "... "
				end

				return " " .. variable.value
			end,
		})

		-- Rust
		dap.configurations.rust = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
		}

		-- C
		dap.configurations.c = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
		}

		-- CPP
		dap.configurations.cpp = {
			{
				name = "Launch",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.expand("%:p:r"), "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				stdio = function()
					local testcases = vim.fn.expand("%:p:r") .. ".testcases"
					if vim.fn.filereadable(testcases) == 0 then
						return nil
					end
					local f = io.open(testcases, "rb")
					local content = f:read("*a")
					f:close()
					-- find "input" marker then skip the msgpack fixstr length byte after it
					local pos = content:find("\xa5input")
					if not pos then
						return nil
					end
					pos = pos + 6 -- skip past "input" (5 chars) + the \xa5 prefix = 6
					-- next byte is msgpack fixstr length (0xa0 | len), skip it
					pos = pos + 1
					-- read until \xa6 which marks "output"
					local input = content:match("^(.-)\xa6output", pos)
					if not input then
						return nil
					end
					local tmp = os.tmpname()
					local out = io.open(tmp, "w")
					out:write(input)
					out:close()
					return { tmp, nil, nil }
				end,
			},
		}

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
				args = { "--port", "${port}" },
			},
		}

		-- Handled by nvim-dap-go
		-- dap.adapters.go = {
		--   type = "server",
		--   port = "${port}",
		--   executable = {
		--     command = "dlv",
		--     args = { "dap", "-l", "127.0.0.1:${port}" },
		--   },
		-- }

		vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
		vim.keymap.set("n", "<space>B", dap.run_to_cursor)

		-- Eval var under cursor
		vim.keymap.set("n", "<space>?", function()
			-- require("dapui").eval(nil, { enter = true })
			require("dapui").eval(vim.fn.expand("<cword>"), { enter = true })
		end)

		vim.keymap.set("n", "<F1>", dap.continue)
		vim.keymap.set("n", "<F2>", dap.step_into)
		vim.keymap.set("n", "<F3>", dap.step_over)
		vim.keymap.set("n", "<F4>", dap.step_out)
		vim.keymap.set("n", "<F5>", dap.step_back)
		vim.keymap.set("n", "<F12>", dap.restart)

		dap.listeners.before.attach.dapui_config = function()
			ui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			ui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			ui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			ui.close()
		end
	end,
}
