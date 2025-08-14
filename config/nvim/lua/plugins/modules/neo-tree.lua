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
            prompt_copy_node_path = function(state)
                -- Inspired by:
                -- https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/370#discussioncomment-6679447

                local node = state.tree:get_node()
                local filepath = node:get_id()
                local filename = node.name
                local modify = vim.fn.fnamemodify

                local options = vim.tbl_filter(
                    function(o) return o.value ~= '' end,
                    {
                        { key = 'Filename     ', value = filename },
                        { key = 'Path (cwd)   ', value = modify(filepath, ':.') },
                        { key = 'Absolute Path', value = filepath },
                        -- { key = 'Basename     ', value = modify(filename, ':r') },
                        -- { key = 'Extension    ', value = modify(filename, ':e') },
                        { key = 'PATH (~)     ', value = modify(filepath, ':~') },
                        { key = 'URI          ', value = vim.uri_from_fname(filepath) },
                    }
                )

                if vim.tbl_isempty(options) then
                    vim.notify('No values to copy', vim.log.levels.WARN)
                    return
                end

                local values = vim.tbl_from_entries(options)
                local items = vim.tbl_map(
                    function(o) return o.key end,
                    options
                )

                vim.ui.select(
                    items,
                    {
                        prompt = 'Choose to copy to clipboard:',
                        format_item = function(item)
                            return ('%s : %s'):format(item, values[item])
                        end,
                    },
                    function(choice)
                        local result = values[choice]
                        if result then
                            vim.notify(('Copied: `%s`'):format(result))
                            vim.fn.setreg('+', result)
                        end
                    end
                )
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
                ['Y'] = 'prompt_copy_node_path',
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
