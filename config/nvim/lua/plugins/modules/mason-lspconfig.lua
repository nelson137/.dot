-- Mason compatibility with lspconfig

return {
    'williamboman/mason-lspconfig',

    lazy = false,

    config = {
        ensure_installed = {
            'eslint',
            'lua_ls',
            'rust_analyzer',
            'tsserver',
        },
    },
}
