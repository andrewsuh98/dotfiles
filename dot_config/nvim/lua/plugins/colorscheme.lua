return {
	{
		"EdenEast/nightfox.nvim",
		lazy = false, -- make sure we load this during startup
		priority = 1000, -- make sure to load this before all the other start plugins
		opts = {
			options = {
				transparent = true,
				styles = { -- Style to be applied to different syntax groups
					comments = "italic", -- Value is any valid attr-list value `:help attr-list`
					conditionals = "NONE",
					constants = "NONE",
					functions = "NONE",
					keywords = "NONE",
					numbers = "NONE",
					operators = "NONE",
					strings = "NONE",
					types = "NONE",
					variables = "NONE",
				},
			},
		},
	},

	-- Configure LazyVim to load nordfox
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "nordfox",
		},
	},
}
