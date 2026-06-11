-- Preview colors in code

return {
    pack = {
        src = { github = 'NvChad/nvim-colorizer.lua' },
    },

    spec = {
        'nvim-colorizer.lua',

        ft = { 'css', 'scss' },

        after = function()
            require('colorizer').setup({
                filetypes = {
                    'css',
                    'scss',
                },
            })
        end,
    },
}
