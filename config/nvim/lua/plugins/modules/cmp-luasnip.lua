-- LuaSnip integration with nvim-cmp

return {
    'saadparwaiz1/cmp_luasnip',

    cond = check_module('cmp'),

    dependencies = { 'hrsh7th/nvim-cmp', 'L3MON4D3/LuaSnip' },
}
