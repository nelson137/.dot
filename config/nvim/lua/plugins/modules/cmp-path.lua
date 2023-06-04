-- Path completion

return {
    'hrsh7th/cmp-path',

    cond = check_module('cmp'),

    dependencies = { 'hrsh7th/nvim-cmp' },
}
