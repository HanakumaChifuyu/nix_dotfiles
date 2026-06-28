require("oil").setup({
	default_file_explorer = true,
	view_options = {
		show_hidden = true,
	},
	watch_for_changes = true,
	keymaps = {

		["g?"] = { "actions.show_help", mode = "n" },
		["<CR>"] = "actions.select",
		["<C-s>"] = false,
		["<C-h>"] = false,
		["<C-t>"] = false,
		["<C-p>"] = false,
		["<C-c>"] = { "actions.close", mode = "n" },
		["<C-l>"] = false,
		["-"] = { "actions.parent", mode = "n" },
		["_"] = { "actions.open_cwd", mode = "n" },
		["`"] = { "actions.cd", mode = "n" },
		["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
		["gs"] = { "actions.change_sort", mode = "n" },
		["gx"] = "actions.open_external",
		["g."] = { "actions.toggle_hidden", mode = "n" },
		["g\\"] = { "actions.toggle_trash", mode = "n" },

		["q"] = "actions.close",
		["C"] = {
			desc = "Copy relative path to clipboard",
			callback = function()
				local oil = require("oil")
				local entry = oil.get_cursor_entry()
				local dir = oil.get_current_dir()

				if not entry or not dir then
					return
				end

				local full_path = dir .. entry.name
				local relative_path = vim.fn.fnamemodify(full_path, ":.")

				if entry.type == "directory" then
					relative_path = relative_path .. "/ "
					vim.fn.setreg("+", relative_path)
				else
					vim.fn.setreg("+", relative_path)
				end
			end,
		},
	},
	float = {
		padding = 2,
		max_width = 0,
		max_height = 0,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
	},
})

require("oil-git").setup({
	debounce_ms = 50,
	show_file_highlights = true,
	show_directory_highlights = true,
	show_file_symbols = true,
	show_directory_symbols = true,
	show_ignored_files = false, -- Show ignored file status
	show_ignored_directories = false, -- Show ignored directory status
	symbol_position = "eol", -- "eol", "signcolumn", or "none"
	can_use_signcolumn = nil, -- Optional callback(bufnr): nil|bool|string
	ignore_gitsigns_update = false, -- Ignore GitSignsUpdate events (fallback for flickering)
	debug = false, -- false, "minimal", or "verbose"

	symbols = {
		file = {
			added = "",
			modified = "",
			renamed = " ",
			deleted = " ",
			copied = "󰆏 ",
			conflict = "󰽜 ",
			untracked = " ",
			ignored = " ",
		},
		directory = {
			added = "",
			modified = " ",
			renamed = " ",
			deleted = " ",
			copied = "󰆏 ",
			conflict = "󰽜 ",
			untracked = " ",
			ignored = " ",
		},
	},

	-- Colors (only applied if highlight groups don't exist)
	highlights = {
		OilGitAdded = { fg = "#00d787" }, -- Bright green
		OilGitModified = { fg = "#ffd700" }, -- Golden yellow
		OilGitRenamed = { fg = "#af5fff" }, -- Bright purple
		OilGitDeleted = { fg = "#ff5f5f" }, -- Bright red
		OilGitCopied = { fg = "#00d7ff" }, -- Bright cyan
		OilGitConflict = { fg = "#ff6600" }, -- Bright orange
		OilGitUntracked = { fg = "#fc03ad" }, -- Bright pink
		OilGitIgnored = { fg = "#808080" }, -- Gray (subtle)
	},
})

-- Force override existing highlight groups
vim.api.nvim_set_hl(0, "OilGitAdded", { fg = "#00d787" })
vim.api.nvim_set_hl(0, "OilGitModified", { fg = "#ffd700" })
vim.api.nvim_set_hl(0, "OilGitRenamed", { fg = "#af5fff" })
vim.api.nvim_set_hl(0, "OilGitDeleted", { fg = "#ff5f5f" })
vim.api.nvim_set_hl(0, "OilGitCopied", { fg = "#00d7ff" })
vim.api.nvim_set_hl(0, "OilGitConflict", { fg = "#ff6600" })
vim.api.nvim_set_hl(0, "OilGitUntracked", { fg = "#fc03ad" })
vim.api.nvim_set_hl(0, "OilGitIgnored", { fg = "#808080" })

-- Note: OilActionsPost autocmd moved to lua/config/autocmds.lua
