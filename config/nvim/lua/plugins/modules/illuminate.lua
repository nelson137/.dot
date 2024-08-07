-- Highlight instances of the symbol under the cursor like VS Code

return {
    'RRethy/vim-illuminate',

    event = 'VeryLazy',

    opts = {
        delay = 300,
    },

    config = function(_, opts)
        require('illuminate').configure(opts)
    end,
}
