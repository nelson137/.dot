-- Terminal window manager

-- Set keymaps on terminal open
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
    group = vim.api.nvim_create_augroup('SetTerminalKeymaps', {}),
    pattern = { 'term://*' },
    callback = function()
        Map('ToggleTerm')('t', '<C-]><C-]>', [[<C-\><C-n>]], 'escape')
    end,
})

return {
    pack = {
        src = { github = 'akinsho/toggleterm.nvim' },
    },

    spec = {
        'toggleterm.nvim',

        keys = {
            {
                '<Leader>tt',
                '<Cmd>ToggleTerm direction=horizontal<CR>',
                desc = 'ToggleTerm: new',
            },
            {
                '<Leader>tf',
                '<Cmd>ToggleTerm direction=float<CR>',
                desc = 'ToggleTerm: floating',
            },
            {
                '<Leader>ts',
                '<Cmd>ToggleTermSendVisualSelection<CR>',
                mode = 'v',
                desc = 'ToggleTerm: send visual selection',
            },
            {
                '<Leader>tl',
                '<Cmd>ToggleTermSendVisualLines<CR>',
                mode = 'v',
                desc = 'ToggleTerm: send visual lines',
            },
        },

        after = function()
            require('toggleterm').setup({
                on_create = function()
                    vim.env.NO_STARSHIP = '1'
                end,
            })
        end,
    },
}
