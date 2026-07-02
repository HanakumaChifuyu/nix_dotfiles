return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = false },
		indent = {
			enabled = false,
			animate = {
				enabled = false,
			},
		},
		scroll = { enabled = false },
		picker = {
			enabled = true,
			ui_select = true,
			sources = {
				files = {
					hidden = true,
				},
				grep = {
					hidden = true,
				},
				smart = {
					hidden = true,
				},
			},
		},
		quickfile = { enabled = true },
		rename = { enabled = true },
		scope = { enabled = false },
		statuscolumn = {
			enabled = true,
		},
		words = { enabled = true },
	},
}
