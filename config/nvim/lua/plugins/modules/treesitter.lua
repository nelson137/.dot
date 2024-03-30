-- Syntax highlighting
--
-- Link: https://github.com/nvim-treesitter/nvim-treesitter

return {
    'nvim-treesitter/nvim-treesitter',

    event = 'BufReadPost',

    main = 'nvim-treesitter.configs',
    config = true,

    build = ':TSUpdate',

    opts = {
        auto_install = true,

        ensure_installed = { 'comment' },

        highlight = {
            enable = true,
        },

        indent = {
            enable = true,
        },
    },
}
