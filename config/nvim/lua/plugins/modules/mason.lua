-- Neovim package manager (language servers, linters, formaters, etc.)

return {
    'mason-org/mason.nvim',

    event = { 'BufReadPre', 'BufNewFile' },

    dependencies = { 'neovim/nvim-lspconfig' },

    opts = {
        registries = {
            'github:mason-org/mason-registry',
            'github:Crashdummyy/mason-registry',
        },
    },
}
