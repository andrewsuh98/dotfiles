return {
	"nvim-lualine/lualine.nvim",
	opts = {
		sections = {
			lualine_y = {
				{ "progress", separator = " ", padding = { left = 1, right = 0 } },
				{
					function()
						return " " .. vim.fn.line("$") -- Gets total number of lines
					end,
				},
			},
			lualine_z = {
				{ "location", padding = { left = 0, right = 1 } },
				-- function()
				-- 	return " " .. os.date("%R")
				-- end,
			},
		},
	},
}
