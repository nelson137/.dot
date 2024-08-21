-- Autocompletion

local feedkey = function(keys, mode)
    local resolved_keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
    vim.api.nvim_feedkeys(resolved_keys, mode or '', true)
end

local action_tab = function(fallback)
    if vim.fn['vsnip#jumpable'](1) == 1 then
        feedkey('<Plug>(vsnip-jump-next)')
    else
        fallback() -- sends the mapped key
    end
end

local action_shift_tab = function(fallback)
    if vim.fn['vsnip#jumpable'](-1) == 1 then
        feedkey('<Plug>(vsnip-jump-prev)')
    else
        fallback() -- sends the mapped key
    end
end

return {
    'hrsh7th/nvim-cmp',

    -- Completion config
    -- See [config options](https://github.com/hrsh7th/nvim-cmp#basic-configuration)
    opts = function()
        local cmp = require('cmp')
        -- cmp.mapping
        return {
            preselect = cmp.PreselectMode.None,
            snippet = {
                expand = function(args)
                    vim.fn['vsnip#anonymous'](args.body)
                end,
            },
            mapping = {
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-n>'] = cmp.mapping.select_next_item(),

                ['<Tab>'] = cmp.mapping(action_tab, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(action_shift_tab, { 'i', 's' }),

                ['<C-k>'] = cmp.mapping.scroll_docs(-4),
                ['<C-j>'] = cmp.mapping.scroll_docs(4),

                ['<C-]>'] = cmp.mapping.close(),
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
