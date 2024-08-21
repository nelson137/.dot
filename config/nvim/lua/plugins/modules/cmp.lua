-- Autocompletion

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
