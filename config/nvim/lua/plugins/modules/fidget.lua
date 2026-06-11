-- Language server progress visualizer

return {
    pack = {
        src = { github = 'j-hui/fidget.nvim' },
    },

    spec = {
        'fidget.nvim',

        event = 'LspAttach',

        after = function()
            require('fidget').setup()
        end,
    },
}
