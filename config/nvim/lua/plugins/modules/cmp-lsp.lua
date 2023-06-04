-- LSP completion

return {
    'hrsh7th/cmp-nvim-lsp',

    cond = check_module('cmp'),

    dependencies = { 'hrsh7th/nvim-cmp' },
}
