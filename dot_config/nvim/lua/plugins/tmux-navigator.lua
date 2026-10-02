-- Inside herdr (and not tmux), move between splits and hand focus to the
-- neighboring herdr pane at an edge. Otherwise defer to vim-tmux-navigator.
local function navigate(wincmd, dir, tmux_cmd)
	local pane = vim.env.HERDR_PANE_ID
	if (vim.env.TMUX or "") ~= "" or (pane or "") == "" then
		vim.cmd(tmux_cmd)
		return
	end
	local win = vim.api.nvim_get_current_win()
	vim.cmd.wincmd(wincmd)
	if vim.api.nvim_get_current_win() == win then
		local herdr = vim.env.HERDR_BIN_PATH or "herdr"
		vim.system({ herdr, "pane", "focus", "--direction", dir, "--pane", pane })
	end
end

return {
	"christoomey/vim-tmux-navigator",
	lazy = false,
	init = function()
		-- The plugin's default maps would override the herdr-aware keys below
		vim.g.tmux_navigator_no_mappings = 1
	end,
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
		"TmuxNavigatorProcessList",
	},
	keys = {
		{ "<c-h>", function() navigate("h", "left", "TmuxNavigateLeft") end },
		{ "<c-j>", function() navigate("j", "down", "TmuxNavigateDown") end },
		{ "<c-k>", function() navigate("k", "up", "TmuxNavigateUp") end },
		{ "<c-l>", function() navigate("l", "right", "TmuxNavigateRight") end },
		{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
	},
}
