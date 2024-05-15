-- Autocompletion

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local action_tab = function(fallback)
    local cmp = require('cmp')
    if cmp.visible() then
        cmp.select_next_item()
    elseif vim.fn['vsnip#available'](1) == 1 then
        feedkey('<Plug>(vsnip-expand-or-jump)', '')
    elseif has_words_before() then
        cmp.complete()
    else
        -- The fallback function sends an already mapped key. In this case, it's probably `<Tab>`.
        fallback()
    end
end

local action_shift_tab = function()
    local cmp = require('cmp')
    if cmp.visible() then
        cmp.select_prev_item()
    elseif vim.fn['vsnip#jumpable'](-1) == 1 then
        feedkey('<Plug>(vsnip-jump-prev)', '')
    end
end

return {
    'hrsh7th/nvim-cmp',

    -- Completion config
    -- See [config options](https://github.com/hrsh7th/nvim-cmp#basic-configuration)
    opts = function()
        local cmp = require('cmp')
        return {
            preselect = cmp.PreselectMode.None,
            snippet = {
                expand = function(args)
                    vim.fn['vsnip#anonymous'](args.body)
                end,
            },
            mapping = {
                -- ['<C-p>'] = cmp.mapping.select_prev_item(),
                -- ['<C-n>'] = cmp.mapping.select_next_item(),

                -- ['<Tab>'] = cmp.mapping.select_next_item(),
                -- ['<S-Tab>'] = cmp.mapping.select_prev_item(),

                ['<Tab>'] = cmp.mapping(action_tab, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(action_shift_tab, { 'i', 's' }),

                ['<C-k>'] = cmp.mapping.scroll_docs(-4),
                ['<C-j>'] = cmp.mapping.scroll_docs(4),

                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.close(),

                ['<CR>'] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                }),
            },

            -- Installed sources
            sources = {
                { name = 'nvim_lsp' },
                { name = 'nvim_lsp_signature_help' },
                { name = 'vsnip' },
                { name = 'path' },
                -- { name = 'buffer' },
            },
        }
    end,
}
