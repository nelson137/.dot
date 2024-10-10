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

        vim.keymap.set('n', '<C-n>', illuminate.goto_next_reference,
            { desc = "Illuminate: goto next reference" })
        vim.keymap.set('n', '<C-m>', illuminate.goto_prev_reference,
            { desc = "Illuminate: goto prev reference" })
    end,
}
