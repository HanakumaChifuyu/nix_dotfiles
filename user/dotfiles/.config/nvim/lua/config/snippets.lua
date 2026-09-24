-- Blink uses vim.snippet: distinguish placeholders from the selected text.
local function set_highlights()
	vim.api.nvim_set_hl(0, "SnippetTabstop", { underline = true })
	vim.api.nvim_set_hl(0, "SnippetTabstopActive", { underline = true, bold = true })
end

local group = vim.api.nvim_create_augroup("SnippetAppearance", { clear = true })
set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	desc = "Keep snippet placeholders distinct from Visual selections",
	callback = set_highlights,
})

-- Select mode replaces placeholder text as you type, but shares Visual's
-- guicursor entry. Temporarily use a beam, preserving other modes' styles.
local saved_guicursor
vim.api.nvim_create_autocmd("ModeChanged", {
	group = group,
	desc = "Use an insertion cursor while replacing selected text",
	callback = function()
		local mode = vim.v.event.new_mode:sub(1, 1)
		local selecting = mode == "s" or mode == "S" or mode == "\19"
		if selecting and saved_guicursor == nil and vim.o.guicursor ~= "" then
			saved_guicursor = vim.o.guicursor
			vim.opt.guicursor:append("v-ve:ver25")
		elseif not selecting and saved_guicursor ~= nil then
			vim.o.guicursor = saved_guicursor
			saved_guicursor = nil
		end
	end,
})
