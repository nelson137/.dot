-- Commenter
--
-- Alternatives:
--   - preservim/nerdcommenter
--   - tomtom/tcomment_vim

vim.pack.add({
    { src = 'https://github.com/JoosepAlviste/nvim-ts-context-commentstring' }
}, { load = function() end })

return {
    pack = {
        src = { github = 'numToStr/Comment.nvim' },
    },

    spec = {
        'Comment.nvim',

        event = 'BufReadPost',

        before = function()
            vim.cmd.packadd('nvim-ts-context-commentstring')
        end,

        after = function()
            local commenter = require('ts_context_commentstring.integrations.comment_nvim')
            require('Comment').setup({
                toggler = {
                    line = '<Leader>/',
                },

                pre_hook = commenter.create_pre_hook(),
            })
        end,
    },
}
