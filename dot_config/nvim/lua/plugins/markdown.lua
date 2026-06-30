return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	ft = { "markdown" },
	keys = {
		{ "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Markdown Preview" },
	},
}
