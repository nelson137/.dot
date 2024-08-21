-- Snippet engine

local function feedkey(keys, mode)
    local resolved_keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
    vim.api.nvim_feedkeys(resolved_keys, mode or '', true)
end

local function jump_next_placeholder()
    if vim.fn['vsnip#jumpable'](1) == 1 then
        feedkey('<Plug>(vsnip-jump-next)')
    end
end

local function jump_prev_placeholder()
    if vim.fn['vsnip#jumpable'](-1) == 1 then
        feedkey('<Plug>(vsnip-jump-prev)')
    end
end

return {
    'hrsh7th/vim-vsnip',

    config = function()
        vim.keymap.set({ 'i', 's' }, '<Tab>', jump_next_placeholder, { desc = 'Snippet: jump to next placeholder' })
        vim.keymap.set({ 'i', 's' }, '<S-Tab>', jump_prev_placeholder, { desc = 'Snippet: jump to previous placeholder' })
    end,
}
