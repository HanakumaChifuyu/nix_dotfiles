return {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = {
        { "echasnovski/mini.icons", opts = {} },
        {
            "malewicz1337/oil-git.nvim",
            dependencies = { "stevearc/oil.nvim" },
            opts = {
                show_file_highlights = true,
                show_directory_highlights = false,
                show_ignored_files = true,
            },
        },
    },
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
}
