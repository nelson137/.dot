-- Configure Roslyn language server
-- TODO: https://www.youtube.com/watch?v=yJc4AWf0TNs
-- * debug & test runner

return {
    'seblyng/roslyn.nvim',

    ft = { 'cs' },

    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {},
}
