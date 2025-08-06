-- Tree file explorer

local P = {
    command = function() return require('neo-tree.command') end,
}
setmetatable(P, {
    __call = function() return require('neo-tree') end,
})

return {
    'nvim-neo-tree/neo-tree.nvim',

    branch = 'v3.x',

    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-tree/nvim-web-devicons',
        -- { '3rd/image.nvim', opts = {} }, -- TODO: enable this for image preview
    },

    lazy = false,

    ---@module 'neo-tree'
    ---@type neotree.Config
    opts = {
        sources = { 'filesystem', 'buffers', 'document_symbols' },
        source_selector = {
            statusline = true,
            sources = {
                { source = 'filesystem' },
                { source = 'buffers' },
                { source = 'document_symbols' },
            },
            truncation_character = '…',
        },
        default_component_configs = {
            container = {
                max_width = 74,
            },
        },
        commands = {
            focus_filesystem = function()
                P.command().execute({ action = 'focus', source = 'filesystem' })
            end,
            focus_buffers = function()
                P.command().execute({ action = 'focus', source = 'buffers' })
            end,
            focus_document_symbols = function()
                P.command().execute({ action = 'focus', source = 'document_symbols' })
            end,
        },
        window = {
            auto_expand_width = true,
            mappings = {
                ['e'] = 'focus_filesystem',
                ['E'] = 'focus_buffers',
                ['Q'] = 'focus_document_symbols',
                ['<C-j>'] = { 'scroll_preview', config = { direction = 10 } },
                ['<C-k>'] = { 'scroll_preview', config = { direction = -10 } },
                -- TODO: add mappings to find with telescope
                --       https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes#find-with-telescope
                -- TODO: add mappings to open file with diffview
                -- TODO: implement LSP reference updates on file rename
                --       https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes#handle-rename-or-move-file-event
                --       implement this function's logic:
                --       https://github.com/pmizio/typescript-tools.nvim/blob/3c501d7c7f79457932a8750a2a1476a004c5c1a9/lua/typescript-tools/api.lua#L158
            },
        },
        filesystem = {
            filtered_items = {
                visible = false,
                hide_gitignored = true,
                hide_dotfiles = false,
            },
            follow_current_file = {
                enabled = true,
                leave_dirs_open = false,
            },
            use_libuv_file_watcher = false,
            mappings = {
                ['f'] = 'filter_on_submit',
                ['<C-x>'] = 'clear_filter',
            },
        },
    },

    config = function(_, opts)
        P().setup(opts)

        local function toggle_source(source)
            return function()
                P.command().execute({ action = 'focus', source = source, toggle = true })
            end
        end

        local map = Map('NeoTree')
        map('n', '<Leader>e', toggle_source('filesystem'), 'toggle filesystem')
        map('n', '<Leader>E', toggle_source('buffers'), 'toggle buffers')
    end,
}
