hl.curve("wind", { type = "spring", mass = 1.0, stiffness = 70, dampening = 19 })
hl.curve("winIn", { type = "spring", mass = 1.0, stiffness = 65, dampening = 18 })
hl.curve("winOut", { type = "spring", mass = 1.0, stiffness = 75, dampening = 20 })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

hl.curve("md3_standard", { type = "spring", mass = 1.0, stiffness = 60, dampening = 17 })
hl.curve("md3_decel", { type = "spring", mass = 1.0, stiffness = 50, dampening = 15 })
hl.curve("md3_accel", { type = "spring", mass = 1.0, stiffness = 70, dampening = 19 })
hl.curve("md2", { type = "spring", mass = 1.0, stiffness = 50, dampening = 15 })

hl.curve("overshot", { type = "spring", mass = 1.0, stiffness = 90, dampening = 16 })
hl.curve("crazyshot", { type = "spring", mass = 1.0, stiffness = 120, dampening = 17 })
hl.curve("OutBack", { type = "spring", mass = 1.0, stiffness = 100, dampening = 18 })

hl.curve("hyprnostretch", { type = "spring", mass = 1.0, stiffness = 110, dampening = 24 })

hl.curve("menu_decel", { type = "spring", mass = 1.0, stiffness = 65, dampening = 18 })
hl.curve("menu_accel", { type = "spring", mass = 1.0, stiffness = 75, dampening = 20 })

hl.curve("easeInOutCirc", { type = "spring", mass = 1.0, stiffness = 55, dampening = 16 })
hl.curve("easeOutCirc", { type = "spring", mass = 1.0, stiffness = 55, dampening = 16 })
hl.curve("easeOutExpo", { type = "spring", mass = 1.0, stiffness = 60, dampening = 17 })
hl.curve("softAcDecel", { type = "spring", mass = 1.0, stiffness = 45, dampening = 14 })

hl.animation({ leaf = "borderangle", enabled = true, speed = 82, bezier = "liner", style = "once" })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 5.5, spring = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4.8, spring = "easeOutCirc" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5.2, spring = "wind", style = "slide" })

hl.animation({ leaf = "fade", enabled = true, speed = 3.5, spring = "md3_decel" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.5, spring = "menu_decel", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3.0, spring = "menu_accel" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3.2, spring = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 3.5, spring = "menu_accel" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 6.0, spring = "menu_decel", style = "slide" })
hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 4.5,
	spring = "md3_decel",
	style = "slidefadevert 15%",
})
