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
	local ok, out, _ = wezterm.run_child_process({ "cat", "/proc/stat" })
	if not ok then return "N/A" end
	local u, n, s, id, io, irq, si =
		out:match("^cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
	if not u then return "N/A" end
	u, n, s, id, io, irq, si = tonumber(u), tonumber(n), tonumber(s), tonumber(id), tonumber(io), tonumber(irq), tonumber(si)
	local total = u + n + s + id + io + irq + si
	local d_total = total - cpu_prev.total
	local d_idle = id - cpu_prev.idle
	cpu_prev.total = total
	cpu_prev.idle = id
	if d_total == 0 then return "  0%" end
	local pct = (d_total - d_idle) / d_total * 100
	return string.format("%3.0f%%", pct)
end

local function read_mem_usage()
	local ok, out, _ = wezterm.run_child_process({ "cat", "/proc/meminfo" })
	if not ok then return "N/A" end
	local total = tonumber(out:match("MemTotal:%s+(%d+)"))
	local available = tonumber(out:match("MemAvailable:%s+(%d+)"))
	if not total or not available or total == 0 then return "N/A" end
	local used_gb = (total - available) / 1024 / 1024
	local total_gb = total / 1024 / 1024
	return string.format("%4.1f/%3.0fG", used_gb, total_gb)
end

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

	-- CPU / 内存
	local cpu_text = " 󰻠 " .. read_cpu_usage() .. " "
	local mem_text = " 󰘚 " .. read_mem_usage() .. " "

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
