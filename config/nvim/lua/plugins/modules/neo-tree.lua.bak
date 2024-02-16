-- Tree file explorer

vim.g.neo_tree_remove_legacy_commands = 1

local show_neo_tree = function()
    require('neo-tree.command').execute({})
end

-- commands = {
--     'open_and_close_window' = function()
--         -- open
--         -- close_window
--     end
-- }

return {
    'nvim-neo-tree/neo-tree.nvim',

    branch = 'v2.x',

    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-tree/nvim-web-devicons'
    },

    event = 'VeryLazy',

    keys = {
        { '<Leader>e', show_neo_tree },
    },

    opts = {
        filesystem = {
            filtered_items = {
                visible = false,
                hide_gitignored = true,
            },
            follow_current_file = true,
            use_libuv_file_watcher = false,
            window = {
                mappings = {
                    -- ['/'] = 'set_root',
                    -- ['f'] = 'fuzzy_finder',
                },
            },
        },
        source_selector = {
            statusline = true,
            sources = {
                { source = 'filesystem' },
                { source = 'document_symbols' },
            },
        },
        sources = { 'filesystem', 'document_symbols', 'git_status' },
        -- window = {
        --     mappings = {
        --         ['<CR>'] = function(state)
        --         end,
        --     },
        -- },
    },
}
