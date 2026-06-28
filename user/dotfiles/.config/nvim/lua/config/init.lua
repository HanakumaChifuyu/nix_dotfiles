require("notify").setup({
	fps = 60,
	render = "minimal",
	timeout = 200,
})
vim.notify = require("notify")

local config_path = vim.fn.stdpath("config") .. "/lua/config/"
-- Get a config list for require
-- @param path string Configuration file directory
-- @return table A table includes all moudles inside path
local function get_config_modules(path)
	local results = {}
	local fd = vim.uv.fs_scandir(path)
	if not fd then
		vim.notify("Can't find config directory:" .. path, vim.log.levels.ERROR)
		return results
	end

	local name
	while true do
		name, _ = vim.uv.fs_scandir_next(fd)
		if not name then
			break
		end
		name = name:gsub(".lua", "")
		table.insert(results, name)
	end
	return results
end

local modules = get_config_modules(config_path)

for _, module_name in ipairs(modules) do
	if module_name ~= "lazy" and module_name ~= "init" then
		local success, err = pcall(function()
			require("config." .. module_name)
		end)
		if not success then
			vim.notify("Error loading config module " .. module_name .. ":" .. tostring(err), vim.log.levels.ERROR)
		end
	end
end
