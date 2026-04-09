local separator = { "────────────────────────────────────────────", hl = "NonText" }

local function key_item(key, desc, action, opts)
	-- Pad description to fixed width so all entries align when centered
	local width = 24
	local padded = desc .. string.rep(" ", width - #desc)
	return {
		text = { { " " .. key .. "    ", hl = "Identifier" }, { padded, hl = "Normal" } },
		align = "center",
		key = key,
		action = action,
		padding = 0,
		enabled = opts and opts.enabled,
		section = opts and opts.section,
	}
end

return {
	"snacks.nvim",
	opts = {
		dashboard = {
			formats = {
				header = { "%s", align = "center" },
				footer = { "%s", align = "center" },
			},
			sections = {
				-- Logo line 1: cyan left, green from diagonal onward
				{
					text = {
						{ "│ ", hl = "Special" },
						{ "╲ ││", hl = "String" },
					},
					align = "center",
					padding = 0,
				},
				-- Logo line 2
				{
					text = {
						{ "││", hl = "Special" },
						{ "╲╲││", hl = "String" },
					},
					align = "center",
					padding = 0,
				},
				-- Logo line 3
				{
					text = {
						{ "││ ", hl = "Special" },
						{ "╲ │", hl = "String" },
					},
					align = "center",
					padding = 1,
				},
				-- Version
				{
					text = {
						{ "NVIM v" .. tostring(vim.version()), hl = "String" },
					},
					align = "center",
					padding = 0,
				},
				-- Separator
				{ text = { separator }, align = "center", padding = 0 },
				-- Menu keys
				key_item("f", "Find File", ":lua Snacks.dashboard.pick('files')"),
				key_item("n", "New File", ":ene | startinsert"),
				key_item("g", "Find Text", ":lua Snacks.dashboard.pick('live_grep')"),
				key_item("r", "Recent Files", ":lua Snacks.dashboard.pick('oldfiles')"),
				key_item("c", "Config", ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})"),
				key_item("s", "Restore Session", nil, { section = "session" }),
				key_item("x", "Lazy Extras", ":LazyExtras"),
				key_item("L", "Lazy", ":Lazy", { enabled = package.loaded.lazy ~= nil }),
				key_item("q", "Quit", ":qa"),
				-- Separator
				{ text = { separator }, align = "center", padding = 0 },
				-- Neovim commands
				key_item("h", "Help", ":help"),
				key_item("H", "Checkhealth", ":checkhealth"),
				key_item("N", "News", ":help news"),
				-- Separator
				{ text = { separator }, align = "center", padding = 0 },
				-- Startup (no lightning emoji)
				{
					section = "startup",
					icon = "",
				},
			},
		},
	},
}
