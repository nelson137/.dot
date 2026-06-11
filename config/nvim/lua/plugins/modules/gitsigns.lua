-- Git buffer info

return {
    pack = {
        src = { github = 'lewis6991/gitsigns.nvim' },
    },

    spec = {
        'gitsigns.nvim',

        event = 'BufReadPost',

        after = function()
            require('gitsigns').setup({
                current_line_blame = false,
                current_line_blame_formatter = '<author> (<author_time:%R>) <summary>',

                on_attach = function(bufnr)
                    local gs = require('gitsigns')
                    local gs_actions = require('gitsigns.actions')

                    local map = Map('Git', { buffer = bufnr })

                    -- Navigation
                    map('n', ']c', function()
                        if vim.wo.diff then return ']c' end
                        vim.schedule(function() gs.next_hunk() end)
                        return '<Ignore>'
                    end, 'go to next hunk')
                    map('n', '[c', function()
                        if vim.wo.diff then return '[c' end
                        vim.schedule(function() gs.prev_hunk() end)
                        return '<Ignore>'
                    end, 'go to previous hunk')

                    -- Actions
                    map('n', '<Leader>hs', gs.stage_hunk, 'stage hunk')
                    map('n', '<Leader>hS', gs.stage_buffer, 'stage entire buffer')
                    map('n', '<Leader>hr', gs.reset_hunk, 'discard hunk changes')
                    map('n', '<Leader>hR', gs.reset_buffer, 'discard buffer changes')
                    map('n', '<Leader>hu', gs.undo_stage_hunk, 'unstage hunk')
                    map('n', '<Leader>hp', gs.preview_hunk, 'preview hunk')
                    map('n', '<Leader>hd', gs.diffthis)
                    map('n', '<Leader>b', gs_actions.toggle_current_line_blame, 'toggle current line blame')

                    -- Text objects
                    map({ 'o', 'x' }, 'ih', '<C-u>:Gitsigns select_hunk<CR>', 'select hunk under cursor')
                end,
            })
        end,
    },
}
