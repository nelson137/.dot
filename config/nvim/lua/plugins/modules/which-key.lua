-- Key binding popup window

return {
    pack = {
        src = { github = 'folke/which-key.nvim' },
    },

    spec = {
        'which-key.nvim',

        event = 'DeferredUIEnter',

        after = function()
            require('which-key').setup({})
        end,
    },
}
