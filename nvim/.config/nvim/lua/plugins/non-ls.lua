return {
	"nvimtools/none-ls.nvim",
	event = "BufWritePre",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.gofmt,
				null_ls.builtins.formatting.clang_format.with({
					extra_args = { "--style={BasedOnStyle: LLVM, IndentWidth: 4}" },
				}),
				null_ls.builtins.formatting.google_java_format.with({
					extra_args = { "--aosp" },
				}),
			},
		})
		vim.keymap.set("n", "tm", function()
			vim.lsp.buf.format({ name = "null-ls" })
		end, {})
		local notify = vim.notify
		vim.notify = function(msg, ...)
			if type(msg) == "string" and msg:match("timeout") then
				return
			end
			notify(msg, ...)
		end
	end,
}
