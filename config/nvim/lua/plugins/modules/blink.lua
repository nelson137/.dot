return {
    'saghen/blink.cmp',

    version = '1.*',

    dependencies = { 'L3MON4D3/LuaSnip' },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = 'enter',
            ['<C-j>'] = { 'scroll_documentation_down', 'fallback' },
            ['<C-k>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-b>'] = {},
            ['<C-f>'] = {},
        },
        completion = {
            documentation = {
                auto_show = true,
            },
            list = {
                selection = {
                    preselect = false,
                },
            },
        },
        fuzzy = {
            implementation = 'prefer_rust_with_warning',
        },
        snippets = {
            preset = 'luasnip',
        },
    },
}
