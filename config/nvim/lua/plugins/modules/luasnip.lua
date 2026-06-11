-- Snippet engine

-- friendly-snippets: snippet data consumed by the vscode loader below. Installed
-- (not sourced) here so the dependency lives next to its only consumer; it is
-- packadded in `before`.
vim.pack.add({
    { src = 'https://github.com/rafamadriz/friendly-snippets', version = '9a91957168c0ba4b14291d9ebefc83a36165d1b8' }
}, { load = function() end })

return {
    pack = {
        src = { github = 'L3MON4D3/LuaSnip' },
        version = vim.version.range('2.*'),
    },

    spec = {
        'LuaSnip',

        -- Loaded on demand by blink.cmp (its snippet engine) via `trigger_load`.
        lazy = true,

        before = function()
            vim.cmd.packadd('friendly-snippets')
        end,

        after = function()
            local lsnip = require('luasnip')
            lsnip.setup({})

            require('luasnip.loaders.from_vscode').lazy_load({ paths = './snippets' })

            local map = Map('LuaSnip')
            map({ 'i', 's' }, '<C-l>', function() lsnip.jump(1) end, 'jump to next placeholder')
            map({ 'i', 's' }, '<C-h>', function() lsnip.jump(-1) end, 'jump to prev placeholder')

            map({ 'i', 's' }, '<C-e>', function()
                if lsnip.choice_active() then
                    lsnip.change_choice(1)
                end
            end, 'change choice node')
        end,
    },
}
