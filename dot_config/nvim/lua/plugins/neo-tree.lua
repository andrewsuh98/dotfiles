return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
		},
		filesystem = {
			use_libuv_file_watcher = true,
		},
	},
}
