return {
	"klafyvel/vim-slime-cells",
	dependencies = {
		{
			"jpalardy/vim-slime",
			init = function()
				vim.g.slime_no_mappings = 1
			end,
		},
	},
	lazy = false,

	config = function()
		vim.g.slime_target = "tmux"
		vim.g.slime_default_config = {
			socket_name = "default",
			target_pane = "{last}",
		}
		vim.g.slime_cell_delimiter = "# %%"
		vim.g.slime_bracketed_paste = 1
		vim.g.slime_dont_ask_default = 0
	end,

	keys = {
		{
			"<C-c><C-c>",
			"<Plug>SlimeCellsSendAndGoToNext",
			mode = "n",
			desc = "Send cell and go to next",
		},
		{
			"<C-c><C-c>",
			"<Plug>SlimeRegionSend",
			mode = "v",
			desc = "Send visual selection",
		},
		{
			"<C-c><C-n>",
			"<Plug>SlimeCellsNext",
			mode = "n",
			desc = "Go to next cell",
		},
		{
			"<C-c><C-p>",
			"<Plug>SlimeCellsPrev",
			mode = "n",
			desc = "Go to previous cell",
		},
	},
}
