-- Typescript language server that improves on `typescript-language-server`

return {
    'pmizio/typescript-tools.nvim',

    event = { 'BufReadPre', 'BufNewFile' },

    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },

    config = true,
}
