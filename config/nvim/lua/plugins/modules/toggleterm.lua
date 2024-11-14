-- Terminal window manager

-- Set keymaps on terminal open
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
    group = vim.api.nvim_create_augroup('SetTerminalKeymaps', {}),
    pattern = { 'term://*' },
    callback = function()
        local function map(lhs, rhs, desc)
            local opts = { buffer = 0, desc = 'ToggleTerm: ' .. desc }
            vim.keymap.set('t', lhs, rhs, opts)
        end
        map('<C-]><C-]>', [[<C-\><C-n>]], 'escape')
    end,
})

return {
    'akinsho/toggleterm.nvim',

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

    opts = {
        on_create = function()
            vim.env.NO_STARSHIP = '1'
        end,
    },

    config = function(_, opts)
        require('toggleterm').setup(opts)
    end,
}
