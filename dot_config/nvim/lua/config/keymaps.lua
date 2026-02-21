-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- remove lazyvim window mappings
map("n", "<leader>ww", "<Nop>")
map("n", "<leader>wd", "<Nop>")
map("n", "<leader>w-", "<Nop>")
map("n", "<leader>w|", "<Nop>")
map("n", "<leader>-", "<Nop>")
map("n", "<leader>|", "<Nop>")
map("n", "<C-Up>", "<Nop>")
map("n", "<C-Down>", "<Nop>")
map("n", "<C-Left>", "<Nop>")
map("n", "<C-Right>", "<Nop>")

-- resize windows
map("n", "<C-w><Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-w><Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-w><Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-w><Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
map("n", "<C-w>m", "<C-w>_", { desc = "Max out height" })
map("n", "<C-w>M", "<C-w>|", { desc = "Max out width" })
map("n", "<C-w>c", "<cmd>close<cr>", { desc = "Close window" })

-- Increment/decrement
map("n", "+", "<C-a>", { desc = "Increment number" })
map("n", "-", "<C-x>", { desc = "Decrement number" })

-- Select all
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- Yank the first diagnostic on the current line
map("n", "yd", function()
	local bufnr = 0 -- Current buffer
	local cursor_pos = vim.api.nvim_win_get_cursor(0) -- Get cursor position (row, col)
	local line = cursor_pos[1] - 1 -- Convert to 0-based index

	-- Get diagnostics at the current line
	local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

	if #diagnostics == 0 then
		print("No diagnostics to yank.")
		return
	end

	-- Copy only the first diagnostic message
	local message = diagnostics[1].message
	vim.fn.setreg("+", message) -- Copy to system clipboard
	print("First in-line diagnostic yanked")
end, { desc = "Yank first diagnostic message" })

-- Yank all diagnostics on the current line
map("n", "yD", function()
	local bufnr = 0 -- Current buffer
	local cursor_pos = vim.api.nvim_win_get_cursor(0) -- Get cursor position (row, col)
	local line = cursor_pos[1] - 1 -- Convert to 0-based index

	-- Get all diagnostics at the current line
	local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

	if #diagnostics == 0 then
		print("No diagnostics to yank.")
		return
	end

	-- Collect all diagnostic messages
	local messages = {}
	for _, diag in ipairs(diagnostics) do
		table.insert(messages, diag.message)
	end

	-- Concatenate messages into a single string with line breaks
	local result = table.concat(messages, "\n")
	vim.fn.setreg("+", result) -- Copy to system clipboard
	print("All in-line diagnostics yanked")
end, { desc = "Yank all diagnostic messages" })
