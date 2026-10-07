-- Tree file explorer

vim.pack.add({
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/MunifTanjim/nui.nvim' },
}, { load = function() end })

local P = {
    command = function() return require('neo-tree.command') end,
}
setmetatable(P, {
    __call = function() return require('neo-tree') end,
})

---@module 'neo-tree'
---@type neotree.Config
local opts = {
    close_if_last_window = true,
    enable_diagnostics = false,
    enable_git_status = false,
    popup_border_style = '',
    default_component_configs = {
        file_size = { enabled = false },
        last_modified = { enabled = false, format = 'relative' },
        type = { enabled = false },
    },
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
            ['<C-j>'] = { 'scroll_preview', config = { direction = -10 } },
            ['<C-k>'] = { 'scroll_preview', config = { direction = 10 } },
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
        window = {
            mappings = {
                ['<space>'] = 'noop',
                ['[c'] = 'prev_git_modified',
                [']c'] = 'next_git_modified',
                ['[g'] = 'noop',
                [']g'] = 'noop',
            },
        },
    },
    buffers = {
        commands = {
            safe_buffer_delete = function(state)
                local selected_node = state.tree:get_node()
                if not selected_node then return end

                local stack = { selected_node }
                local file_nodes = {}

                -- Recursively find files that are children of the current node
                while #stack > 0 do
                    local node = table.remove(stack)
                    if node.type == 'directory' then
                        local children = state.tree:get_nodes(node.id)
                        if type(children) == 'table' then
                            for _i, child in ipairs(children) do
                                stack[#stack + 1] = child
                            end
                        end
                    elseif node.type == 'file' then
                        file_nodes[#file_nodes + 1] = node
                    end
                end

                -- Close all discovered descendant file nodes
                for _i, node in ipairs(file_nodes) do
                    local bufnr = node.extra.bufnr
                    local info = vim.fn.getbufinfo(bufnr)[1]

                    if info.hidden == 0 then
                        local buffers = vim.tbl_filter(function(b)
                            local b_info = vim.fn.getbufinfo(b)[1]
                            return b_info.loaded == 1 and b_info.listed == 1
                        end, vim.api.nvim_list_bufs())

                        if #buffers < 2 then return end

                        local prev_i = -1
                        for i, b in ipairs(buffers) do
                            if b == bufnr then
                                prev_i = i - 1
                            end
                        end
                        if prev_i < 1 then prev_i = #buffers end

                        vim.api.nvim_win_set_buf(info.windows[1], buffers[prev_i])
                    end

                    vim.api.nvim_buf_delete(bufnr, { force = false, unload = false })
                end

                require('neo-tree.sources.buffers.commands').refresh()
            end,
        },
        window = {
            mappings = {
                ['d'] = 'safe_buffer_delete',
                ['bd'] = 'noop',
            },
        },
    },
    document_symbols = {
        window = {
            mappings = {
                ['<C-r>'] = 'noop'
            }
        },
    },
}

return {
    pack = {
        src = { github = 'nvim-neo-tree/neo-tree.nvim' },
        version = 'v3.x',
    },

    spec = {
        'neo-tree.nvim',

        lazy = false,

        before = function()
            vim.cmd.packadd('plenary.nvim')
            vim.cmd.packadd('nui.nvim')
        end,

        after = function()
            P().setup(opts)

            local map = Map('NeoTree')

            local function toggle_neo_tree()
                P.command().execute({ action = 'focus', toggle = true })
            end
            map('n', '<Leader>e', toggle_neo_tree, 'toggle')
        end,
    },
}
