-- WezTerm 配置文件
---@module 'wezterm'
local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- ========== 字体 ==========
-- 主字体处理 ASCII，Sarasa Fixed SC 回退处理中文（中文字宽 = 英文 2 倍，终端对齐最佳）
config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono", weight = "Regular" },
	{ family = "Sarasa Fixed SC", weight = "Regular" },
})
config.font_size = 12.0

-- ========== 外观 ==========
config.color_scheme = "Tokyo Night"

-- 窗口边距
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 2,
}

-- 标题栏 / tab bar
config.window_decorations = "NONE"
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false

-- ========== 性能 ==========
config.max_fps = 60
config.animation_fps = 60
-- 状态栏刷新间隔（毫秒），默认 1000ms 导致 Copy Mode 提示有明显延迟
config.status_update_interval = 50

-- ========== 鼠标滚轮步进 ==========
-- 覆盖默认滚轮绑定，每次滚动 1 行（默认为 3）
config.mouse_bindings = {
	{ event = { Down = { streak = 1, button = { WheelUp = 1 } } }, mods = "NONE", action = act.ScrollByLine(-1) },
	{ event = { Down = { streak = 1, button = { WheelDown = 1 } } }, mods = "NONE", action = act.ScrollByLine(1) },
}

-- ========== 激活窗格高亮 ==========
config.inactive_pane_hsb = {
	saturation = 0.2,
	brightness = 0.5,
}

-- ========== Tokyo Night 配色常量 ==========
local C = {
	bg = "#1a1b26",
	bar_bg = "#15161e",
	active_bg = "#7aa2f7",
	active_fg = "#15161e",
	inactive_bg = "#24283b",
	inactive_fg = "#565f89",
	new_tab_bg = "#15161e",
	new_tab_fg = "#565f89",
	split = "#7aa2f7",
	cpu_bg = "#9ece6a",
	cpu_fg = "#1a1b26",
	mem_bg = "#bb9af7",
	mem_fg = "#1a1b26",
	copy_bg = "#e0af68",
	copy_fg = "#1a1b26",
}

-- ========== 标签栏颜色 ==========
config.colors = {
	split = C.split,
	tab_bar = {
		background = C.bar_bg,
		active_tab = {
			bg_color = C.active_bg,
			fg_color = C.active_fg,
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = C.inactive_bg,
			fg_color = C.inactive_fg,
		},
		inactive_tab_hover = {
			bg_color = "#2f3549",
			fg_color = "#a9b1d6",
		},
		new_tab = {
			bg_color = C.new_tab_bg,
			fg_color = C.new_tab_fg,
		},
		new_tab_hover = {
			bg_color = "#24283b",
			fg_color = "#a9b1d6",
		},
	},
}

-- ========== Powerline 风格 Tab 标题 ==========
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider --
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider --

-- ========== CPU / 内存采样 ==========
local cpu_prev = { total = 0, idle = 0 }

local function read_cpu_usage()
	local f = io.open("/proc/stat", "r")
	if not f then
		return "N/A"
	end
	local line = f:read("*l")
	f:close()
	local u, n, s, id, io_w, irq, si = line:match("^cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
	if not u then
		return "N/A"
	end
	u, n, s, id, io_w, irq, si =
		tonumber(u), tonumber(n), tonumber(s), tonumber(id), tonumber(io_w), tonumber(irq), tonumber(si)
	local total = u + n + s + id + io_w + irq + si
	local d_total = total - cpu_prev.total
	local d_idle = id - cpu_prev.idle
	cpu_prev.total = total
	cpu_prev.idle = id
	if d_total == 0 then
		return "  0%"
	end
	local pct = (d_total - d_idle) / d_total * 100
	return string.format("%3.0f%%", pct)
end

local function read_mem_usage()
	local f = io.open("/proc/meminfo", "r")
	if not f then
		return "N/A"
	end
	local out = f:read("*a")
	f:close()
	local total = tonumber(out:match("MemTotal:%s+(%d+)"))
	local available = tonumber(out:match("MemAvailable:%s+(%d+)"))
	if not total or not available or total == 0 then
		return "N/A"
	end
	local used_gb = (total - available) / 1024 / 1024
	local total_gb = total / 1024 / 1024
	return string.format("%4.1f/%3.0fG", used_gb, total_gb)
end

-- CPU / 内存结果缓存，避免 50ms 高频刷新导致数值乱跳
local STATS_INTERVAL = 2 -- 每隔 N 秒才重新采样一次
local stats_cache = { cpu = "N/A", mem = "N/A", last_t = 0 }

-- ========== 右侧状态栏 ==========
wezterm.on("update-right-status", function(window, pane)
	-- 当前工作目录
	local cwd = ""
	local cwd_uri = pane:get_current_working_dir()
	if cwd_uri then
		local path = cwd_uri.file_path or ""
		-- 把 home 目录替换为 ~
		path = path:gsub("^" .. os.getenv("HOME"), "~")
		cwd = " 󰉋 " .. path .. " "
	end

	-- CPU / 内存（节流：每 STATS_INTERVAL 秒采样一次，其余帧复用缓存）
	local now = os.time()
	if now - stats_cache.last_t >= STATS_INTERVAL then
		stats_cache.cpu = read_cpu_usage()
		stats_cache.mem = read_mem_usage()
		stats_cache.last_t = now
	end
	local cpu_text = " 󰻠 " .. stats_cache.cpu .. " "
	local mem_text = " 󰘚 " .. stats_cache.mem .. " "

	-- 当前时间
	local time = " 󰥔 " .. wezterm.strftime("%H:%M") .. " "

	window:set_right_status(wezterm.format({
		-- 目录块
		{ Background = { Color = C.bar_bg } },
		{ Foreground = { Color = C.inactive_bg } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = C.inactive_bg } },
		{ Foreground = { Color = "#a9b1d6" } },
		{ Text = cwd },
		-- CPU 块
		{ Background = { Color = C.inactive_bg } },
		{ Foreground = { Color = C.cpu_bg } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = C.cpu_bg } },
		{ Foreground = { Color = C.cpu_fg } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = cpu_text },
		-- 内存块
		{ Background = { Color = C.cpu_bg } },
		{ Foreground = { Color = C.mem_bg } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = C.mem_bg } },
		{ Foreground = { Color = C.mem_fg } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = mem_text },
		-- 时间块
		{ Background = { Color = C.mem_bg } },
		{ Foreground = { Color = C.active_bg } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = C.active_bg } },
		{ Foreground = { Color = C.active_fg } },
		{ Attribute = { Intensity = "Bold" } },
		{ Text = time },
	}))

	-- ========== 左侧 Copy Mode 提示 ==========
	local key_table = window:active_key_table()
	if key_table == "copy_mode" then
		window:set_left_status(wezterm.format({
			{ Background = { Color = C.bar_bg } },
			{ Foreground = { Color = C.copy_bg } },
			{ Text = SOLID_RIGHT_ARROW },
			{ Background = { Color = C.copy_bg } },
			{ Foreground = { Color = C.copy_fg } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = "  COPY " },
			{ Background = { Color = C.bar_bg } },
			{ Foreground = { Color = C.copy_bg } },
			{ Text = SOLID_RIGHT_ARROW },
		}))
	else
		window:set_left_status("")
	end
end)

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, max_width)
	local title = tab.active_pane.title
	-- 取进程名（去掉路径）
	local proc = tab.active_pane.foreground_process_name
	if proc and proc ~= "" then
		proc = proc:match("([^/\\]+)$") or proc
		title = proc
	end
	-- 加 tab 序号
	local index = tostring(tab.tab_index + 1)
	local prefix = index .. "  "

	-- 截断标题：两侧箭头各占 1 格，空格和前缀占若干，留出余量
	local reserved = #prefix + 4 -- 两端空格 + 箭头
	local max_title = max_width - reserved
	if #title > max_title and max_title > 1 then
		title = wezterm.truncate_right(title, max_title - 1) .. "…"
	end

	if tab.is_active then
		return {
			{ Background = { Color = C.bar_bg } },
			{ Foreground = { Color = C.active_bg } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = C.active_bg } },
			{ Foreground = { Color = C.active_fg } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " " .. prefix .. title .. " " },
			{ Background = { Color = C.bar_bg } },
			{ Foreground = { Color = C.active_bg } },
			{ Text = SOLID_RIGHT_ARROW },
		}
	else
		return {
			{ Background = { Color = C.bar_bg } },
			{ Foreground = { Color = C.inactive_bg } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = C.inactive_bg } },
			{ Foreground = { Color = C.inactive_fg } },
			{ Text = " " .. prefix .. title .. " " },
			{ Background = { Color = C.bar_bg } },
			{ Foreground = { Color = C.inactive_bg } },
			{ Text = SOLID_RIGHT_ARROW },
		}
	end
end)

-- ========== 按键 ==========
config.keys = {
	-- 复制 / 粘贴（Ctrl+C 仅在有选区时复制，否则透传中断信号；Ctrl+V 粘贴）
	{
		key = "c",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local sel = window:get_selection_text_for_pane(pane)
			if sel and sel ~= "" then
				window:copy_to_clipboard(sel)
			else
				window:perform_action(act.SendKey({ key = "c", mods = "CTRL" }), pane)
			end
		end),
	},
	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },

	-- 进入 Copy Mode（vim 风格选择终端输出）
	{ key = "/", mods = "ALT", action = act.ActivateCopyMode },

	-- 新建 tab
	{ key = "n", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
	-- 分割窗格（水平 / 垂直）
	{ key = "\\", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- 切换 tab
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
	-- 关闭 tab / 窗格
	{ key = "w", mods = "ALT", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "q", mods = "ALT", action = act.CloseCurrentPane({ confirm = true }) },
	-- 切换窗格
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	-- 滚动（上下各 2 行）
	{ key = "k", mods = "CTRL|SHIFT", action = act.ScrollByLine(-2) },
	{ key = "j", mods = "CTRL|SHIFT", action = act.ScrollByLine(2) },
	-- 调整窗格大小（Alt+Shift+方向键，每次 3 格）
	{ key = "h", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },
	{ key = "l", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },
	{ key = "k", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 3 }) },
	{ key = "j", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 3 }) },
}

return config
