-- Tree file explorer

--- @param sub_path string?
local function P(sub_path)
    local path = 'neo-tree'
    if sub_path then
        path = path .. '.' .. sub_path
    end
    return require(path)
end

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
    ---@type neotree.Config?
    opts = {
        sources = { 'filesystem', 'buffers', 'document_symbols' },
        source_selector = {
            statusline = true,
            sources = {
                { source = 'filesystem' },
                { source = 'buffers' },
                { source = 'document_symbols' },
            },
        },
        window = {
            width = 74,
            mappings = {
                ['<C-j>'] = { 'scroll_preview', config = { direction = 10 } },
                ['<C-k>'] = { 'scroll_preview', config = { direction = -10 } },
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
            renderers = {
                -- TODO: dynamically insert these configs by filtering the arrays from
                -- `require('neo-tree.defaults').renderers.{file,directory}`
                file = {
                    { "indent" },
                    { "icon" },
                    {
                        "container",
                        content = {
                            { "name",           zindex = 10 },
                            { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
                            { "clipboard",      zindex = 10 },
                            { "bufnr",          zindex = 10 },
                            { "modified",       zindex = 20, align = "right" },
                            { "diagnostics",    zindex = 20, align = "right" },
                            { "git_status",     zindex = 10, align = "right" },
                            -- { "file_size",      zindex = 10, align = "right" },
                            -- { "type",           zindex = 10, align = "right" },
                            -- { "last_modified",  zindex = 10, align = "right" },
                            { "created",        zindex = 10, align = "right" },
                        },
                    },
                },
                directory = {
                    { "indent" },
                    { "icon" },
                    { "current_filter" },
                    {
                        "container",
                        content = {
                            { "name",           zindex = 10 },
                            { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
                            { "clipboard",      zindex = 10 },
                            { "diagnostics",    zindex = 20, align = "right",                        hide_when_expanded = true, errors_only = true },
                            { "git_status",     zindex = 10, align = "right",                        hide_when_expanded = true },
                            -- { "file_size",      zindex = 10, align = "right" },
                            -- { "type",           zindex = 10, align = "right" },
                            -- { "last_modified",  zindex = 10, align = "right" },
                            { "created",        zindex = 10, align = "right" },
                        },
                    },
                },
            },
        },
    },

    config = function(_, opts)
        P().setup(opts)

        vim.keymap.set('n', '<Leader>e', function()
            P('command').execute({ action = 'focus', source = 'filesystem', toggle = true })
        end, { desc = 'NeoTree: toggle filesystem' })
    end,
}
