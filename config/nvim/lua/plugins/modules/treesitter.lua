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
        auto_install = false,

        -- Supported languages: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
        ensure_installed = {
            'bash',
            'c',
            'css',
            'diff',
            'git_config',
            'git_rebase',
            'gitcommit',
            'gitignore',
            'jsonc',
            'lua',
            'markdown',
            'markdown_inline',
            'python',
            'rust',
            'scss',
            'svelte',
            'typescript',
            'vim',
            'vimdoc',
            'yaml',
        },

        highlight = {
            enable = true,
        },

        indent = {
            enable = true,
        },
    },
}
