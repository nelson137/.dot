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
        local live_grep_args = require('telescope-live-grep-args.shortcuts')

        telescope.setup(opts)
        telescope.load_extension('fzf')
        telescope.load_extension('live_grep_args')

        local map = Map('Telescope')

        map('n', '<Leader>fF', builtin.find_files, 'find files')
        map('n', '<Leader>fb', builtin.buffers, 'find buffers')
        map('n', '<Leader><F12>', builtin.grep_string,
            'search for string under cursor or selection')
        map('n', '<Leader>ff', _git_files, 'find git files')
        map('n', '<Leader>gc', builtin.git_commits, 'list commits')
        map('n', '<Leader>gC', builtin.git_bcommits, 'list commits for current buffer')
        map('n', '<Leader>gs', builtin.git_status, 'show git status')

        map('n', '<Leader>F', telescope.extensions.live_grep_args.live_grep_args,
            'live grep (args)')
        map('v', '<Leader>F', live_grep_args.grep_visual_selection,
            'live grep current selection (global)')
        map('v', '<Leader>B', live_grep_args.grep_word_visual_selection_current_buffer,
            'live grep current selection (current buffer)')
    end,
}
