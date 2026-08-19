hl.config({

	xwayland = {
		force_zero_scaling = true,
	},

	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 3,
		resize_on_border = true,
		allow_tearing = false,
		layout = "dwindle",
	},

	render = {
		-- Keep the SDR monitor in SDR when a fullscreen client advertises HDR.
		cm_auto_hdr = 0,
	},

	decoration = {
		rounding = 20,
		rounding_power = 2,
		blur = {
			enabled = true,
			size = 5,
			passes = 1,
			new_optimizations = true,
			xray = false,
			popups = true,
		},
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
	},

	input = {
		repeat_rate = 60,
		repeat_delay = 400,
		touchpad = {
			disable_while_typing = true,
		},
	},

	cursor = {
		inactive_timeout = 3,       -- 鼠标停止移动 3 秒后自动隐藏
		hide_on_key_press = true,   -- 敲击键盘时自动隐藏鼠标
	},

	group = {
		merge_groups_on_drag = true,
		merge_groups_on_groupbar = true,
		merge_floated_into_tiled_on_groupbar = true,
		col = {
			border_active = 0xee88c0d0,
			border_inactive = 0xee4c566a,
			border_locked_active = 0xeeff6666,
			border_locked_inactive = 0xee5e81ac,
		},
		groupbar = {
			enabled = true,
			font_family = "",
			font_size = 18,
			height = 20,
			scrolling = true,
			render_titles = true,
			text_offset = 0,
			text_color = 0xffffffff,
			text_color_inactive = 0xddffffff,
			col = {
				inactive = 0xee3b4252,
				locked_active = 0xeeab2a2a,
				locked_inactive = 0xee4c566a,
			},
			indicator_height = 3,
			indicator_gap = 0,
			rounding = 3,
			gradients = false,
			gaps_in = 2,
			gaps_out = 2,
		},
	},

	binds = {
		drag_threshold = 20,
		movefocus_cycles_fullscreen = true,
	},

	gestures = {
		workspace_swipe_distance = 260,
		workspace_swipe_cancel_ratio = 0.35,
		workspace_swipe_create_new = false,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 12,
	},

	misc = {
		enable_swallow = true,
		initial_workspace_tracking = 1,
		-- Adaptive Sync only for fullscreen content such as games.
		vrr = 2,
	},
})
