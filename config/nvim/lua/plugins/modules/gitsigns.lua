-- Git buffer info

-- TODO

return {
    'lewis6991/gitsigns.nvim',

    dependencies = { 'nvim-lua/plenary.nvim' },

    event = 'BufReadPost',

    opts = {
        on_attach = function(bufnr)
            local gs = require('gitsigns')

            local map = function(mode, lhs, rhs, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, lhs, rhs, opts)
            end

            -- Navigation
            map('n', ']c', function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
            end)
            map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
            end)

            -- Actions
            map('n', '<Leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
            map('n', '<Leader>hS', gs.stage_buffer, { desc = 'Stage entire buffer'})
            map('n', '<Leader>hr', gs.reset_hunk, { desc = 'Discard hunk changes' })
            map('n', '<Leader>hR', gs.reset_buffer, { desc = 'Discard buffer changes' })
            map('n', '<Leader>hu', gs.undo_stage_hunk, { desc = 'Unstage hunk' })
            map('n', '<Leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
            map('n', '<Leader>hd', gs.diffthis)

            -- Text objects
            map({ 'o', 'x' }, 'ih', '<C-u>:Gitsigns select_hunk<CR>')
        end,
    },

    config = true,
}
