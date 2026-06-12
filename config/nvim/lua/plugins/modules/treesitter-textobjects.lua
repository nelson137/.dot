-- Syntax-aware text-objects: select, swap, and move support for treesitter

return {
    pack = {
        src = { github = 'nvim-treesitter/nvim-treesitter-textobjects' },
        version = 'main',
    },

    spec = {
        'nvim-treesitter-textobjects',

        event = 'BufReadPost',

        after = function()
            require('nvim-treesitter-textobjects').setup({
                select = {
                    lookahead = true,

                    -- Options:
                    --   - 'v': charwise
                    --   - 'V': linewise
                    --   - '<C-v>': blockwise
                    selection_modes = {
                        ['@class.inner'] = 'V',
                        ['@class.outer'] = 'V',
                        ['@statement.outer'] = 'V',
                    },

                    include_surrounding_whitespace = false,
                },
            })

            local select = require('nvim-treesitter-textobjects.select')
            local swap = require('nvim-treesitter-textobjects.swap')

            -- Select
            local select_map = Map('Select textobject')
            for lhs, obj in pairs({
                ['ia'] = '@parameter.inner',
                ['aa'] = '@parameter.outer',
                ['if'] = '@function.inner',
                ['af'] = '@function.outer',
                ['ic'] = '@class.inner',
                ['ac'] = '@class.outer',
                ['ax'] = '@comment.outer',
                ['as'] = '@statement.outer',
            }) do
                select_map({ 'x', 'o' }, lhs, function()
                    select.select_textobject(obj, 'textobjects')
                end, obj)
            end

            -- Swap
            local swap_next_map = Map('Swap textobject with next')
            for lhs, obj in pairs({
                ['gal'] = '@parameter.inner',
                ['gfj'] = '@function.outer',
                ['gcj'] = '@class.outer',
            }) do
                swap_next_map('n', lhs, function() swap.swap_next(obj) end, obj)
            end

            local swap_prev_map = Map('Swap textobject with previous')
            for lhs, obj in pairs({
                ['gah'] = '@parameter.inner',
                ['gfk'] = '@function.outer',
                ['gck'] = '@class.outer',
            }) do
                swap_prev_map('n', lhs, function() swap.swap_previous(obj) end, obj)
            end
        end,
    },
}
