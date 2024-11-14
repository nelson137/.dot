-- Popup to find, filter, preview, or pick

local _git_files = function()
    require('telescope.builtin').git_files({ show_untracked = true })
end

return {
    'nvim-telescope/telescope.nvim',

    event = 'VeryLazy',

    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-live-grep-args.nvim' },

    opts = {
        defaults = {
            layout_strategy = 'vertical',
            -- layout_config = {
            --     layout_config = { width = 0.9 },
            -- },
            mappings = {
                i = {
                    ['<C-t>'] = function(...)
                        require('trouble.sources.telescope').open(...)
                    end,
                },
            },
        },
    },

    config = function(_, opts)
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')

        telescope.setup(opts)
        telescope.load_extension('fzf')
        telescope.load_extension('live_grep_args')

        vim.keymap.set('n', '<Leader>fF', builtin.find_files,
            { desc = 'Telescope: find files' })
        vim.keymap.set('n', '<Leader>fb', builtin.buffers,
            { desc = 'Telescope: find buffers' })
        vim.keymap.set('n', '<Leader><F12>', builtin.grep_string,
            { desc = 'Telescope: search for string under cursor or selection' })
        vim.keymap.set('n', '<Leader>ff', _git_files,
            { desc = 'Telescope: find git files' })
        vim.keymap.set('n', '<Leader>gc', builtin.git_commits,
            { desc = 'Telescope: list commits' })
        vim.keymap.set('n', '<Leader>gC', builtin.git_bcommits,
            { desc = 'Telescope: list commits for current buffer' })
        vim.keymap.set('n', '<Leader>gs', builtin.git_status,
            { desc = 'Telescope: show git status' })

        vim.keymap.set('n', '<Leader>F', telescope.extensions.live_grep_args.live_grep_args,
            { desc = 'Telescope: live grep (args)' })
        local live_grep_args = require('telescope-live-grep-args.shortcuts')
        vim.keymap.set('v', '<Leader>F', live_grep_args.grep_visual_selection,
            { desc = 'Telescope: live grep current selection (global)' })
        vim.keymap.set('v', '<Leader>B', live_grep_args.grep_word_visual_selection_current_buffer,
            { desc = 'Telescope: live grep current selection (current buffer)' })
    end,
}
