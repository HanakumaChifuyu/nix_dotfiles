return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = { "MunifTanjim/nui.nvim" },
	opts = {
		cmdline = { view = "cmdline_popup" },
		-- Keep the existing notification and LSP UI providers.
		notify = { enabled = false },
		lsp = {
			progress = { enabled = false },
			hover = { enabled = false },
			signature = { enabled = false },
			message = { enabled = false },
		},
		presets = {
			command_palette = true,
			long_message_to_split = true,
		},
		views = {
			shell_output = {
				view = "split",
				enter = true,
				position = "bottom",
				size = "30%",
				close = { keys = { "q" } },
				format = { "{message}" },
			},
		},
		routes = {
			{
				filter = { event = "msg_show", kind = { "shell_out", "shell_err", "shell_ret" } },
				view = "shell_output",
			},
		},
	},
}
