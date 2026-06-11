-- Text case converter utility

return {
    pack = {
        src = { github = 'johmsalas/text-case.nvim' },
    },

    spec = {
        'text-case.nvim',

        event = 'DeferredUIEnter',

        -- Registers a telescope extension below.
        before = function()
            require('lz.n').trigger_load('telescope.nvim')
        end,

        after = function()
            require('textcase').setup({})
            require('telescope').load_extension('textcase')
        end,
    },
}
