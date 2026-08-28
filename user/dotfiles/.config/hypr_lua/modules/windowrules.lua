-- Opacity for Kitty clients
hl.window_rule({ match = { class = "kitty" }, opacity = "0.85" })

-- Float XWayland windows (including Wine), no blur/border/rounding
hl.window_rule({
	match = { xwayland = true },
	float = true,
	no_blur = true,
	decorate = false,
	rounding = 0,
	no_anim = true,
})

-- Wine's Wayland driver uses the lower-case Windows executable name as app_id.
-- Hyprland exposes that app_id as `class`, e.g. `notepad.exe`.
hl.window_rule({
	match = { class = ".*\\.(exe|com)$" },
	float = true,
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
