-- A collection of quality of life plugins

return {
    pack = {
        src = { github = 'folke/snacks.nvim' },
    },

    spec = {
        'snacks.nvim',

        lazy = false,
        priority = 1000,

        after = function()
            ---@module 'snacks'
            ---@type snacks.Config
            local opts = {
                bigfile = { enabled = true },
                bufdelete = { enabled = true },
                --dashboard = { enabled = true },
                -- explorer = { enabled = true },
                input = { enabled = true },
                quickfile = { enabled = true },
                words = { enabled = true },
            }

            require('snacks').setup(opts)
        end,
    },
}
