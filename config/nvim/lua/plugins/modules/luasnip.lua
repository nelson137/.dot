-- Snippet engine

return {
    'L3MON4D3/LuaSnip',

    dependencies = { 'rafamadriz/friendly-snippets' },

    version = 'v2.*',
    build = 'make install_jsregexp',

    opts = {},

    config = function(_, opts)
        local lsnip = require('luasnip')
        lsnip.setup(opts)

        require('luasnip.loaders.from_vscode').lazy_load()

        vim.keymap.set({ 'i', 's' }, '<C-l>', function() lsnip.jump(1) end)
        vim.keymap.set({ 'i', 's' }, '<C-h>', function() lsnip.jump(-1) end)

        vim.keymap.set({ 'i', 's' }, '<C-e>', function()
            if lsnip.choice_active() then
                lsnip.change_choice(1)
            end
        end)
    end,
}
