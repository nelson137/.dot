return {
    pack = {
        src = { github = 'romus204/tree-sitter-manager.nvim' },
    },

    spec = {
        'tree-sitter-manager.nvim',

        after = function()
            require('tree-sitter-manager').setup({
                ensure_installed = {
                    'c',
                    'c_sharp',
                    'comment',
                    'css',
                    'csv',
                    'diff',
                    'dockerfile',
                    'git_config',
                    'git_rebase',
                    'gitcommit',
                    'gitignore',
                    'html',
                    'html_tags',
                    'javascript',
                    'json',
                    'lua',
                    'markdown',
                    'markdown_inline',
                    'python',
                    'rust',
                    'svelte',
                    'toml',
                    'tsx',
                    'typescript',
                    'vim',
                    'vimdoc',
                    'yaml',
                },
            })
        end,
    },
}
