-- Git conflict utility

return {
    pack = {
        src = { github = 'akinsho/git-conflict.nvim' },
        version = vim.version.range('*'),
    },

    spec = {
        'git-conflict.nvim',

        event = 'BufReadPost',

        after = function()
            require('git-conflict').setup()
        end,
    },
}
