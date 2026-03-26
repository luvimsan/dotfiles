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

		-- C/C++
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

		dap.configurations.cpp = dap.configurations.c

		-- codelldb
		dap.adapters.codelldb = function(callback)
			local port = math.random(10000, 65000)
			callback({
				type = "server",
				host = "127.0.0.1",
				port = port,
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/codelldb",
					args = {
						"--port",
						tostring(port),
						"--liblldb",
						vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.so",
					},
				},
			})
		end

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
			require("dapui").eval(nil, { enter = true })
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
