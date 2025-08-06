-- Highlight instances of the symbol under the cursor like VS Code

return {
    'RRethy/vim-illuminate',

    event = 'VeryLazy',

    opts = {
        delay = 300,
        filetypes_denylist = { 'yaml' },
    },

    config = function(_, opts)
        local illuminate = require('illuminate')
        illuminate.configure(opts)

        local map = Map('Illuminate')
        map('n', '<C-n>', illuminate.goto_next_reference, 'goto next reference')
        map('n', '<C-m>', illuminate.goto_prev_reference, 'goto prev reference')
    end,
}
