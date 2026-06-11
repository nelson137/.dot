return {
    pack = {
        src = { github = 'saghen/blink.cmp' },
        version = vim.version.range('1.*'),
    },

    spec = {
        'blink.cmp',

        event = { 'InsertEnter', 'CmdlineEnter' },

        before = function()
            require('lz.n').trigger_load('LuaSnip')
        end,

        after = function()
            ---@module 'blink.cmp'
            ---@type blink.cmp.Config
            local opts = {
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
                signature = {
                    enabled = true,
                    window = { show_documentation = true },
                },
                snippets = {
                    preset = 'luasnip',
                },
            }

            require('blink.cmp').setup(opts)
        end,
    },
}
