-- Neovim package manager (language servers, linters, formaters, etc.)

return {
    pack = {
        src = { github = 'mason-org/mason.nvim' },
    },

    spec = {
        'mason.nvim',

        event = { 'BufReadPre', 'BufNewFile' },

        before = function()
            require('lz.n').trigger_load('nvim-lspconfig')
        end,

        after = function()
            require('mason').setup({
                registries = {
                    'github:mason-org/mason-registry',
                    'github:Crashdummyy/mason-registry',
                },
            })
        end,
    },
}
