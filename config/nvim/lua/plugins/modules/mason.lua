-- Neovim package manager (language servers, linters, formaters, etc.)

return {
    'mason-org/mason.nvim',

    event = { 'BufReadPre', 'BufNewFile' },

    dependencies = { 'neovim/nvim-lspconfig' },

    config = true,
}
