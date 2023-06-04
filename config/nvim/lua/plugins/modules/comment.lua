-- Commenter
--
-- Alternatives:
--   - preservim/nerdcommenter
--   - tomtom/tcomment_vim

return {
    'numToStr/Comment.nvim',

    event = 'VeryLazy',

    opts = {
        toggler = {
            line = '<Leader>/',
        },
        opleader = {
            line = 'gc',
        },
    },
}
