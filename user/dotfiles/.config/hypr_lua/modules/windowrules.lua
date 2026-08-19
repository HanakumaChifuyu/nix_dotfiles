-- Opacity for Foot clients
hl.window_rule({ match = { class = "footclient" }, opacity = "0.85" })

-- Dropdown terminal (float + center)
hl.window_rule({
	match = { class = "foot-dropdown" },
	float = true,
	center = true,
	size = { "70%", "60%" },
	opacity = "0.85",
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

-- Gaming & Gamescope (极低延迟直通、全屏、防止息屏)
hl.window_rule({
	match = { class = "gamescope" },
	fullscreen = true,
	idle_inhibit = "focus",
})

hl.window_rule({
	match = { class = "^steam_app_.*" },
	idle_inhibit = "focus",
})
