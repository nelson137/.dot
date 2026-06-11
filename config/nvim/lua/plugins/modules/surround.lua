-- Surround
--
-- Alternatives:
--   - tpope/vim-surround

return {
    pack = {
        src = { github = 'kylechui/nvim-surround' },
    },

    spec = {
        'nvim-surround',

        event = 'DeferredUIEnter',

        after = function()
            require('nvim-surround').setup()
        end,
    },
}
