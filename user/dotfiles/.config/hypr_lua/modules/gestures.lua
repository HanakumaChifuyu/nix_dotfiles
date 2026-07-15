-- Touchpad gestures.
-- Hyprland's built-in gestures are 1:1, so workspace swipes follow finger motion.

-- Three-finger horizontal swipe: move between existing workspaces.
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Four-finger swipe down: toggle the scratchpad special workspace.
hl.gesture({
	fingers = 4,
	direction = "down",
	action = "special",
	workspace_name = "scratchpad",
})

-- Four-finger swipe up: toggle maximized mode for the active window.
hl.gesture({
	fingers = 4,
	direction = "up",
	action = "fullscreen",
	mode = "maximize",
})
