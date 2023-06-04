-- Popup to find, filter, preview, or pick

local _git_files = function()
    require('telescope.builtin').git_files({ show_untracked = true })
end

return {
    'nvim-telescope/telescope.nvim',

    event = 'VeryLazy',

    dependencies = { 'nvim-lua/plenary.nvim' },

    opts = {
        defaults = {
            layout_strategy = 'vertical',
            -- layout_config = {
            --     layout_config = { width = 0.9 },
            -- },
            mappings = {
                i = {
                    ['<CR>'] = 'select_tab',
                },
            },
        },
    },

    config = function(_, opts)
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')

        telescope.setup(opts)
        telescope.load_extension('fzf')

        vim.keymap.set('n', '<Leader>fF', builtin.find_files,
            { desc = 'Telescope: find files' })
        vim.keymap.set('n', '<Leader>fb', builtin.buffers,
            { desc = 'Telescope: find buffers' })
        vim.keymap.set('n', '<Leader>F', builtin.live_grep,
            { desc = 'Telescope: live grep of files' })
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
    end,
}
