-- Function signature completion
--
-- Alternatives:
--   - ray-x/lsp_signature.nvim

return {
    'hrsh7th/cmp-nvim-lsp-signature-help',

    cond = check_module('cmp'),

    dependencies = { 'hrsh7th/nvim-cmp' },
}
