-- Configure Roslyn language server
-- TODO: https://www.youtube.com/watch?v=yJc4AWf0TNs
-- * debug & test runner

return {
    pack = {
        src = { github = 'seblyng/roslyn.nvim' },
    },

    spec = {
        'roslyn.nvim',

        ft = { 'cs' },

        after = function()
            ---@module 'roslyn.config'
            ---@type RoslynNvimConfig
            require('roslyn').setup({})
        end,
    },
}
