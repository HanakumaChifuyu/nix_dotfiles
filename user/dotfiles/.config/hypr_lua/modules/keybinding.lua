local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
local term = "wezterm"

-- ---- basic ----

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. " + semicolon", hl.dsp.exec_cmd("cliphist list | fuzzel -d | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term))

-- Dropdown terminal
hl.bind(
	mainMod .. " + SHIFT + Return",
	hl.dsp.exec_cmd(term .. " start --class wezterm-dropdown")
)

hl.bind(mainMod .. " + Q", hl.dsp.window.close()) -- close active (not kill)
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(scriptsDir .. "/KillActiveWindow.sh")) -- kill active process
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen()) -- whole full screen
hl.bind(mainMod .. " + A", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })) -- fake full screen
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float()) -- float mode
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/Screenshot.sh"))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(scriptsDir .. "/Record.sh"))

-- ---- window control ----

-- Resize windows
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

-- Move windows
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.move({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.move({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.move({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.move({ x = 0, y = 20, relative = true }), { repeating = true })

-- Move focus with mainMod + HJKL
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Swap window position with mainMod + arrow keys
-- NOTE: Using arrows instead of HJKL because keyd remaps Ctrl+HJKL to arrow keys
--       So physically pressing Super+Ctrl+HJKL = Super+arrows in Hyprland
hl.bind(mainMod .. " + left", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.window.swap({ direction = "d" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true }) -- left click
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- right click

-- Cycle next window
hl.bind(mainMod .. " + TAB", hl.dsp.window.cycle_next())

-- ---- workspaces ----

-- The following mappings use the key codes to better support various keyboard layouts
-- 1 is code:10, 2 is code 11, etc
-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + code:10", hl.dsp.focus({ workspace = 1 })) -- key 1
hl.bind(mainMod .. " + code:11", hl.dsp.focus({ workspace = 2 })) -- key 2
hl.bind(mainMod .. " + code:12", hl.dsp.focus({ workspace = 3 })) -- key 3
hl.bind(mainMod .. " + code:13", hl.dsp.focus({ workspace = 4 })) -- key 4
hl.bind(mainMod .. " + code:14", hl.dsp.focus({ workspace = 5 })) -- key 5
hl.bind(mainMod .. " + code:15", hl.dsp.focus({ workspace = 6 })) -- key 6
hl.bind(mainMod .. " + code:16", hl.dsp.focus({ workspace = 7 })) -- key 7
hl.bind(mainMod .. " + code:17", hl.dsp.focus({ workspace = 8 })) -- key 8
hl.bind(mainMod .. " + code:18", hl.dsp.focus({ workspace = 9 })) -- key 9
hl.bind(mainMod .. " + code:19", hl.dsp.focus({ workspace = 10 })) -- key 0

-- Move active window and follow to workspace mainMod + SHIFT [0-9]
hl.bind(mainMod .. " + SHIFT + code:10", hl.dsp.window.move({ workspace = 1 })) -- key 1
hl.bind(mainMod .. " + SHIFT + code:11", hl.dsp.window.move({ workspace = 2 })) -- key 2
hl.bind(mainMod .. " + SHIFT + code:12", hl.dsp.window.move({ workspace = 3 })) -- key 3
hl.bind(mainMod .. " + SHIFT + code:13", hl.dsp.window.move({ workspace = 4 })) -- key 4
hl.bind(mainMod .. " + SHIFT + code:14", hl.dsp.window.move({ workspace = 5 })) -- key 5
hl.bind(mainMod .. " + SHIFT + code:15", hl.dsp.window.move({ workspace = 6 })) -- key 6
hl.bind(mainMod .. " + SHIFT + code:16", hl.dsp.window.move({ workspace = 7 })) -- key 7
hl.bind(mainMod .. " + SHIFT + code:17", hl.dsp.window.move({ workspace = 8 })) -- key 8
hl.bind(mainMod .. " + SHIFT + code:18", hl.dsp.window.move({ workspace = 9 })) -- key 9
hl.bind(mainMod .. " + SHIFT + code:19", hl.dsp.window.move({ workspace = 10 })) -- key 0
hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1" }))

-- Move active window to a workspace silently mainMod + CTRL [0-9]
hl.bind(mainMod .. " + CTRL + code:10", hl.dsp.window.move({ workspace = 1, follow = false })) -- key 1
hl.bind(mainMod .. " + CTRL + code:11", hl.dsp.window.move({ workspace = 2, follow = false })) -- key 2
hl.bind(mainMod .. " + CTRL + code:12", hl.dsp.window.move({ workspace = 3, follow = false })) -- key 3
hl.bind(mainMod .. " + CTRL + code:13", hl.dsp.window.move({ workspace = 4, follow = false })) -- key 4
hl.bind(mainMod .. " + CTRL + code:14", hl.dsp.window.move({ workspace = 5, follow = false })) -- key 5
hl.bind(mainMod .. " + CTRL + code:15", hl.dsp.window.move({ workspace = 6, follow = false })) -- key 6
hl.bind(mainMod .. " + CTRL + code:16", hl.dsp.window.move({ workspace = 7, follow = false })) -- key 7
hl.bind(mainMod .. " + CTRL + code:17", hl.dsp.window.move({ workspace = 8, follow = false })) -- key 8
hl.bind(mainMod .. " + CTRL + code:18", hl.dsp.window.move({ workspace = 9, follow = false })) -- key 9
hl.bind(mainMod .. " + CTRL + code:19", hl.dsp.window.move({ workspace = 10, follow = false })) -- key 0
hl.bind(mainMod .. " + CTRL + bracketleft", hl.dsp.window.move({ workspace = "-1", follow = false }))
hl.bind(mainMod .. " + CTRL + bracketright", hl.dsp.window.move({ workspace = "+1", follow = false }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + period", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + comma", hl.dsp.focus({ workspace = "e-1" }))
