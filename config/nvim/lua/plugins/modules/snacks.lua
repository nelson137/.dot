-- A collection of quality of life plugins

return {
    'folke/snacks.nvim',

    lazy = false,
    priority = 1000,

    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        bufdelete = { enabled = true },
        dashboard = { enabled = true },
        -- explorer = { enabled = true },
        input = { enabled = true },
        quickfile = { enabled = true },
        words = { enabled = true },
    },
}
