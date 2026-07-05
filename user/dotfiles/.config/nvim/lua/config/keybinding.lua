-- ============================================================================
-- Basic Navigation & Editing
-- ============================================================================

-- File manager
vim.keymap.set("n", "<leader>e", "<cmd>Oil --float<CR>", { desc = "Open Oil file manager (float)" })

-- Visual line navigation
vim.keymap.set({ "n", "v" }, "j", "gj", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "k", "gk", { noremap = true, silent = true })

-- Quick save and quit
vim.keymap.set("n", "<leader>w", ":wa<CR>", { noremap = true, desc = "Save all buffers" })
vim.keymap.set("n", "<leader>q", function()
	if #vim.api.nvim_tabpage_list_wins(0) > 1 then
		vim.cmd("q")
	end
end, { noremap = true, desc = "Quit (ignore if last window)" })

-- Quick escape from insert mode
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Buffer navigation
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "Jump to the end of the line" })
vim.keymap.set({ "n", "v" }, "L", "$", { desc = "Jump to the beginning of the line." })
vim.keymap.set("n", "<leader>c", function()
	Snacks.bufdelete()
end, { noremap = true, silent = true, desc = "Close current buffer and go to previous" })

-- Insert blank lines without entering insert mode
vim.keymap.set("n", "o", "o[<BS>", { noremap = true })
vim.keymap.set("n", "O", "O[<BS>", { noremap = true })

-- Paste without overwriting register in visual mode
vim.keymap.set("x", "p", '"_dP', { noremap = true })

-- Copy relative path to system clipboard
vim.keymap.set("n", "C", function()
	local path = vim.fn.expand("%:.")
	vim.fn.setreg("+", path)
end, { desc = "Copy relative path" })

-- ============================================================================
-- LSP & Diagnostics
-- ============================================================================
-- Note: LspAttach autocmd moved to lua/config/autocmds.lua

-- LSP navigation (using Snacks picker)
vim.keymap.set("n", "gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Goto Definition" })
vim.keymap.set("n", "gr", function()
	Snacks.picker.lsp_references()
end, { desc = "References" })

vim.keymap.set("n", "gi", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Goto implementations" })

vim.keymap.set("n", "<leader>ss", function()
	Snacks.picker.lsp_symbols()
end, { desc = "LSP Symbols" })

vim.keymap.set("n", "<leader>sS", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "LSP Workspace Symbols" })

-- LSP actions
vim.keymap.set("n", "gn", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { desc = "LSP Code action" })

-- ============================================================================
-- Plugin-specific Keybindings
-- ============================================================================

-- Leap motion
vim.keymap.set({ "n", "x", "o" }, "f", "<Plug>(leap)")

-- Yanky (yank history)
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")

vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")

vim.keymap.set("n", "]p", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[p", "<Plug>(YankyPutIndentBeforeLinewise)")

vim.keymap.set("n", ">p", "<Plug>(YankyPutIndentAfterShiftRight)")
vim.keymap.set("n", "<p", "<Plug>(YankyPutIndentAfterShiftLeft)")
vim.keymap.set("n", ">P", "<Plug>(YankyPutIndentBeforeShiftRight)")
vim.keymap.set("n", "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)")

vim.keymap.set("n", "=p", "<Plug>(YankyPutAfterFilter)")
vim.keymap.set("n", "=P", "<Plug>(YankyPutBeforeFilter)")

-- ============================================================================
-- Snacks Picker (Fuzzy Finder)
-- ============================================================================

vim.keymap.set("n", "<leader>,", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", function()
	Snacks.picker.grep({ hidden = true })
end, { desc = "Grep" })
vim.keymap.set("n", "<leader>:", function()
	Snacks.picker.command_history()
end, { desc = "Command History" })
vim.keymap.set("n", "<leader>n", function()
	Snacks.picker.notifications()
end, { desc = "Notification History" })

-- Find files
vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fc", function()
	Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files({ hidden = true })
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.git_files()
end, { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker.projects()
end, { desc = "Projects" })
vim.keymap.set("n", "<leader>fr", function()
	Snacks.picker.recent({ filter = { cwd = true } })
end, { desc = "Recent" })

-- Search commands
vim.keymap.set("n", "<leader>sc", function()
	Snacks.picker.command_history()
end, { desc = "Command History" })
vim.keymap.set("n", "<leader>sC", function()
	Snacks.picker.commands()
end, { desc = "Commands" })
vim.keymap.set("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>sD", function()
	Snacks.picker.diagnostics_buffer()
end, { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "<leader>si", function()
	Snacks.picker.icons()
end, { desc = "Icons" })
vim.keymap.set("n", "<leader>sm", function()
	Snacks.picker.marks()
end, { desc = "Marks" })
