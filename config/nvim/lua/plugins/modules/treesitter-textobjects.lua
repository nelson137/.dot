-- Syntax-aware text-objects, select, move, swap, and peek support for treesitter

return {
    'nvim-treesitter/nvim-treesitter-textobjects',

    event = 'BufReadPost',

    dependencies = { 'nvim-treesitter/nvim-treesitter' },

    main = 'nvim-treesitter.configs',
    opts = {
        textobjects = {
            select = {
                enable = true,

                lookahead = true,

                keymaps = {
                    ['ia'] = '@parameter.inner',
                    ['aa'] = '@parameter.outer',
                    ['if'] = '@function.inner',
                    ['af'] = '@function.outer',
                    ['ic'] = '@class.inner',
                    ['ac'] = '@class.outer',
                    ['ax'] = '@comment.outer',
                },

                include_surrounding_whitespace = false
            },

            swap = {
                enable = true,

                swap_next = {
                    ['gal'] = '@parameter.inner',
                    ['gfj'] = '@function.outer',
                    ['gcj'] = '@class.outer',
                },

                swap_previous = {
                    ['gah'] = '@parameter.inner',
                    ['gfk'] = '@function.outer',
                    ['gck'] = '@class.outer',
                },
            },
        },
    },
}
