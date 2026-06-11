-- vim:foldmethod=marker

require('utils')

vim.g.times.mark('init_start')

if vim.loader then
    vim.loader.enable()
end

require('globals')
require('keymaps')
require('plugins')
require('options')

vim.g.times.mark('init_end')
