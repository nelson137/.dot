-- Improve comment support for embedded TS in languages (e.g. `.svelte` files)

return {
    'JoosepAlviste/nvim-ts-context-commentstring',

    dependencies = { 'nvim-treesitter/nvim-treesitter' },

    event = 'BufReadPost',
}
