-- Show code context by keeping lines of the wrapping scope at the top

return {
    'nvim-treesitter/nvim-treesitter-context',

    event = 'BufReadPost',

    dependencies = { 'nvim-treesitter/nvim-treesitter' },

    opts = {
        enable = true,
        max_lines = 8,
    },
}
