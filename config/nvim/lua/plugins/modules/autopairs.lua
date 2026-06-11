-- Automatically handle pairs (brackets, quotes, etc.)
--
-- Alternatives:
--   - echasnovski/mini.pairs

return {
    pack = {
        src = { github = 'windwp/nvim-autopairs' },
    },

    spec = {
        'nvim-autopairs',

        event = 'InsertEnter',

        after = function()
            require('nvim-autopairs').setup()
        end,
    },
}
