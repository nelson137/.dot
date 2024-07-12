-- A diagnostic, reference, telescope result, etc. list

return {
    'folke/trouble.nvim',

    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },

    event = 'BufReadPre',

    keys = {
        {
            '<Leader>xx',
            '<cmd>Trouble diagnostics toggle<CR>',
            desc = 'Trouble: toggle diagnostics',
        },
        {
            '<Leader>xc',
            '<cmd>Trouble diagnostics close<CR>',
            desc = 'Trouble: close diagnostics'},
        {
            '<Leader>xX',
            '<cmd>Trouble diagnostics toggle filter.buf=0<CR>',
            desc = 'Trouble: toggle diagnostics for this buffer',
        },
        {
            '<Leader>cs',
            '<cmd>Trouble symbols toggle focus=false<CR>',
            desc = 'Trouble: toggle buffer symbols',
        },
        {
            '<Leader>cl',
            '<cmd>Trouble lsp toggle win.position=right<CR>',
            desc = 'Trouble: toggle LSP definitions/references/calls/...',
        },
        {
            '<Leader>cr',
            '<cmd>Trouble lsp_references toggle win.position=right<CR>',
            desc = 'Trouble: toggle LSP definitions',
        },
    },

    opts = {
        focus = true,
        preview = {
            type = 'float',
            scratch = true,
            relative = 'editor',
            position = { 4, 10 },
            size = { width = 0.4, height = 0.6 },
            border = 'rounded',
            title = 'Preview',
            title_pos = 'center',
            focusable = false,
        },
    },
}
