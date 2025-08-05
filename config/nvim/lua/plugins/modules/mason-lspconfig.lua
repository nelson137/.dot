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
            'basedpyright',
        },
    },
}
