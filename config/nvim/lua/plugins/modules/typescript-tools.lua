-- Typescript language server that improves on `typescript-language-server`

return {
    'pmizio/typescript-tools.nvim',
    enabled = false,

    event = { 'BufReadPre', 'BufNewFile' },

    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },

    opts = {
        settings = {
            tsserver_file_preferences = {
                importModuleSpecifierPreference = 'project-relative',
            },
        },
    },

    config = true,
}
