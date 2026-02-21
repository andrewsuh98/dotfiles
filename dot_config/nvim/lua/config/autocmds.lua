-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.filetype.add({
	extension = {
		bq = "sql", -- Associate .bq files with the 'sql' file type
	},
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.tmpl",
	callback = function()
		local name = vim.fn.expand("%:r") -- strips the .tmpl extension
		local inner_ext = vim.fn.fnamemodify(name, ":e") -- gets the remaining extension
		if inner_ext ~= "" then
			vim.bo.filetype = inner_ext
		end
	end,
})
