local M = {}

function M.focus_or_leave()
    local filetype = vim.api.nvim_buf_get_option(0, "filetype")
    if filetype == 'neo-tree' then
        vim.cmd('wincmd p')
    else
        require("neo-tree.command").execute({ action = "focus" })
    end
end

return M
