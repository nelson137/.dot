-- vim:foldmethod=marker

-- Timing utility (`vim.g.times`) {{{

local Times = { nanos_per_sec = 1000000000 }

---@param name string
function Times.mark(name)
    local t = vim.uv.hrtime()
    vim.g.times = vim.tbl_deep_extend('keep', vim.g.times, { [name] = t })
end

---@param from string
---@param to string
function Times.get(from, to)
    return (vim.g.times[to] - vim.g.times[from]) / vim.g.times.nanos_per_sec
end

vim.g.times = Times

-- }}}

vim.g.times.mark('init_start')

if vim.loader then
    vim.loader.enable()
end

require('utils')

require('config.global')

require('config.keymaps')

require('plugins')

require('config.options')

require('config.highlights')

require('config.autocmds')

vim.g.times.mark('init_end')
