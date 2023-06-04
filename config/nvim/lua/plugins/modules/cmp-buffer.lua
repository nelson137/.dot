-- Buffer completion

return {
    'hrsh7th/cmp-buffer',

    enabled = false,

    cond = check_module('cmp'),

    dependencies = { 'hrsh7th/nvim-cmp' },
}
