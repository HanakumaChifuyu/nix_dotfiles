-- Opacity for wezterm
hl.window_rule({ match = { class = "org.wezfurlong.wezterm" }, opacity = "0.95" })

-- Dropdown terminal (float + center)
hl.window_rule({
	match = { class = "wezterm-dropdown" },
	float = true,
	center = true,
	size = { "70%", "60%" },
})

-- Float XWayland windows, no blur/border/rounding
hl.window_rule({
	match = { xwayland = true },
	float = true,
	no_blur = true,
	decorate = false,
	rounding = 0,
	no_anim = true,
})

-- Filechooser
hl.window_rule({
	match = { title = "termfilechooser" },
	float = true,
	move = { "50%", "30%" },
	size = { "50%", "50%" },
})

-- anki
hl.window_rule({ match = { class = "anki" }, float = true })
