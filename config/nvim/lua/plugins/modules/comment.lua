-- Commenter
--
-- Alternatives:
--   - preservim/nerdcommenter
--   - tomtom/tcomment_vim

return {
    'numToStr/Comment.nvim',

    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },

    event = 'BufReadPost',

    opts = function()
        local commenter = require('ts_context_commentstring.integrations.comment_nvim')
        return {
            toggler = {
                line = '<Leader>/',
            },

            pre_hook = commenter.create_pre_hook(),
        }
    end,
}
