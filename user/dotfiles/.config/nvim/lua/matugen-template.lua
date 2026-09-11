local M = {}

local transparent_groups = {
	"Normal",
	"NormalNC",
	"NormalFloat",
	"FloatBorder",
	"StatusColumn",
	"StatusColumnNC",
	"SignColumn",
	"FoldColumn",
	"CursorLineSign",
	"CursorLineFold",
	"LineNr",
	"LineNrAbove",
	"LineNrBelow",
	"CursorLineNr",
	"EndOfBuffer",
	"MsgArea",
	"WinSeparator",
	-- Gitsigns derives its line-number highlights from these groups. Clearing
	-- their backgrounds keeps changed-line numbers colored but transparent.
	"GitGutterAdd",
	"GitGutterChange",
	"GitGutterDelete",
	"GitGutterChangeDelete",
}

local gitsigns_types = {
	"Add",
	"Change",
	"Delete",
	"Changedelete",
	"Topdelete",
	"Untracked",
}

function M.apply_transparency()
	local groups = vim.deepcopy(transparent_groups)
	for _, staged in ipairs({ "", "Staged" }) do
		for _, change_type in ipairs(gitsigns_types) do
			groups[#groups + 1] = "GitSigns" .. staged .. change_type .. "Nr"
		end
	end

	for _, group in ipairs(groups) do
		-- Plugin highlight groups might not exist during initial theme setup.
		if vim.fn.hlexists(group) == 1 then
			local definition = vim.api.nvim_get_hl(0, { name = group, link = true })
			-- Keep links intact so Gitsigns continues following Matugen color
			-- changes. Their GitGutter targets are made transparent above.
			if definition.link == nil then
				local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
				highlight.bg = nil
				highlight.ctermbg = nil
				highlight.default = nil
				vim.api.nvim_set_hl(0, group, highlight)
			end
		end
	end
end

function M.setup()
	require("base16-colorscheme").setup({
		-- Background tones
		base00 = "{{colors.surface.default.hex}}", -- Default Background
		base01 = "{{colors.surface_container.default.hex}}", -- Lighter Background (status bars)
		base02 = "{{colors.secondary_container.default.hex}}", -- Selection Background
		base03 = "{{colors.outline.default.hex}}", -- Comments, Invisibles
		-- Foreground tones
		base04 = "{{colors.on_surface_variant.default.hex}}", -- Dark Foreground (status bars)
		base05 = "{{colors.on_surface.default.hex}}", -- Default Foreground
		base06 = "{{colors.on_surface.default.hex}}", -- Light Foreground
		base07 = "{{colors.on_background.default.hex}}", -- Lightest Foreground
		-- Accent colors
		base08 = "{{colors.error.default.hex}}", -- Variables, XML Tags, Errors
		base09 = "{{colors.tertiary.default.hex}}", -- Integers, Constants
		base0A = "{{colors.secondary.default.hex}}", -- Classes, Search Background
		base0B = "{{colors.primary.default.hex}}", -- Strings, Diff Inserted
		base0C = "{{colors.tertiary_fixed_dim.default.hex}}", -- Regex, Escape Chars
		base0D = "{{colors.primary_fixed_dim.default.hex}}", -- Functions, Methods
		base0E = "{{colors.secondary_fixed_dim.default.hex}}", -- Keywords, Storage
		base0F = "{{colors.error_container.default.hex}}", -- Deprecated, Embedded Tags
	})

	-- Let Kitty's transparent background show through Neovim while retaining
	-- each highlight group's foreground and text attributes.
	M.apply_transparency()

	-- 显式覆写选中相关高亮，确保 visual 模式醒目
	local p_bg = "{{colors.primary_container.default.hex}}"
	local p_fg = "{{colors.on_primary_container.default.hex}}"
	local s_bg = "{{colors.secondary_container.default.hex}}"
	local s_fg = "{{colors.on_secondary_container.default.hex}}"
	vim.api.nvim_set_hl(0, "Visual", { bg = p_bg, fg = p_fg })
	vim.api.nvim_set_hl(0, "VisualNOS", { bg = p_bg, fg = p_fg })
	vim.api.nvim_set_hl(0, "Search", { bg = s_bg, fg = s_fg })
	vim.api.nvim_set_hl(0, "IncSearch", { bg = p_bg, fg = p_fg, bold = true })
	vim.api.nvim_set_hl(0, "CurSearch", { bg = p_bg, fg = p_fg, bold = true })
	vim.api.nvim_set_hl(0, "MatchParen", { bg = s_bg, fg = s_fg, bold = true })
end

local transparency_group = vim.api.nvim_create_augroup("MatugenTransparency", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = transparency_group,
	desc = "Restore transparent editor and gutter backgrounds",
	callback = function()
		-- Run after plugin ColorScheme handlers recreate their highlight groups.
		vim.schedule(M.apply_transparency)
	end,
})

-- Register a signal handler for SIGUSR1 (matugen updates)
local signal = vim.uv.new_signal()
signal:start(
	"sigusr1",
	vim.schedule_wrap(function()
		package.loaded["matugen"] = nil
		require("matugen").setup()
	end)
)

return M
