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
            end, { desc = "Git: next hunk"})
            map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
            end, { desc = "Git: previous hunk"})

            -- Actions
            map('n', '<Leader>hs', gs.stage_hunk, { desc = 'Git: stage hunk' })
            map('n', '<Leader>hS', gs.stage_buffer, { desc = 'Git: stage entire buffer'})
            map('n', '<Leader>hr', gs.reset_hunk, { desc = 'Git: discard hunk changes' })
            map('n', '<Leader>hR', gs.reset_buffer, { desc = 'Git: discard buffer changes' })
            map('n', '<Leader>hu', gs.undo_stage_hunk, { desc = 'Git: unstage hunk' })
            map('n', '<Leader>hp', gs.preview_hunk, { desc = 'Git: preview hunk' })
            map('n', '<Leader>hd', gs.diffthis)

            -- Text objects
            map({ 'o', 'x' }, 'ih', '<C-u>:Gitsigns select_hunk<CR>')
        end,
    },

    config = true,
}
