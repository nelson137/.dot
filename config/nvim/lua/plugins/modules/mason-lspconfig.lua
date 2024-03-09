-- Mason compatibility with lspconfig

return {
    'williamboman/mason-lspconfig',

    event = { 'BufReadPre', 'BufNewFile' },

    dependencies = { 'williamboman/mason.nvim' },

    opts = {
        ensure_installed = {
            'eslint',
            'lua_ls',
            'rust_analyzer',
        },

        handlers = {
            function(server)
                require('lspconfig')[server].setup({})
            end,
            ['rust_analyzer'] = function()
                -- noop
            end,
        },
    },
}
