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
