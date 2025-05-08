-- Mason compatibility with lspconfig

return {
    'mason-org/mason-lspconfig.nvim',

    event = { 'BufReadPre', 'BufNewFile' },

    dependencies = { 'williamboman/mason.nvim' },

    opts = {
        automatic_enable = {
            exclude = {
                'rust_analyzer',
                'ts_ls',
            },
        },

        ensure_installed = {
            'angularls@17.3.1',
            'eslint',
            'lua_ls',
            'rust_analyzer',
            'ts_ls',
        },

        handlers = {
            function(server)
                require('lspconfig')[server].setup({})
            end,

            angularls = function()
                local util = require('lspconfig.util')

                require('lspconfig').angularls.setup({
                    filetypes = { 'html' },
                    root_dir = util.root_pattern('angular.json', 'nx.json'),
                })
            end,

            lua_ls = function()
                require('lspconfig').lua_ls.setup({
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            telemetry = { enable = false },
                        },
                    },
                })
            end,

            rust_analyzer = function()
                -- no setup, handled by `rustaceanvim`
            end,

            ts_ls = function()
                -- no setup, handled by `typescript-tools.nvim`
            end,
        },
    },
}
