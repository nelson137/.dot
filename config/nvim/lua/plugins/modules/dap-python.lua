return {
    pack = {
        src = { github = 'mfussenegger/nvim-dap-python' },
    },

    spec = {
        'nvim-dap-python',

        ft = 'python',

        before = function()
            require('lz.n').trigger_load('nvim-dap')
        end,

        after = function()
            require('dap-python').setup('uv')
        end,
    },
}
