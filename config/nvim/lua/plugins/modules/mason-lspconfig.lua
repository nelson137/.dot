-- Mason compatibility with lspconfig

return {
    'mason-org/mason-lspconfig.nvim',

    event = { 'BufReadPre', 'BufNewFile' },

    dependencies = { 'williamboman/mason.nvim' },

    ---@module 'mason-lspconfig'
    ---@type MasonLspconfigSettings
    opts = {
        automatic_enable = {
            exclude = {
                'rust_analyzer',
                'ts_ls',
            },
        },

        ensure_installed = {
            'angularls',
            'eslint',
            'lua_ls',
            -- 'netcoredbg', -- Mason can't install packages from 3rd-party registries
            -- 'roslyn', -- Mason can't install packages from 3rd-party registries
            'rust_analyzer',
            'ts_ls',
            'basedpyright',
        },
    },
}
