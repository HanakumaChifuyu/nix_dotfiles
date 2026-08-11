return {
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose" },
		opts = {
			use_icons = false,
			enhanced_diff_hl = true,
			view = {
				default = {
					layout = "diff2_horizontal",
				},
			},
			file_panel = {
				win_config = {
					width = 28,
				},
			},
		},
	},
}
