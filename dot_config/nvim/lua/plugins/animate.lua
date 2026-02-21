return {
	"snacks.nvim",
	opts = {

		scroll = {
			enabled = true,
			animate = {
				-- default: step = 15, total = 250
				duration = { step = 5, total = 150 },
				easing = "linear",
				fps = 120,
			},

			-- faster animation when repeating scroll after delay
			animate_repeat = {
				delay = 50, -- delay in ms before using the repeat animation
				duration = { step = 5, total = 25 }, -- default: step = 5, total = 50
				easing = "linear",
			},
		},

		indent = {
			animate = {
				enabled = true,
				duration = {
					step = 15, -- default: 20
					total = 400, -- default: 500
				},
			},
		},
	},
}
