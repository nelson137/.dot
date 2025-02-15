-- Autocompletion

local function scroll_docs(delta)
    return function(fallback)
        local cmp = require('cmp')
        if cmp.visible_docs() then
            cmp.scroll_docs(delta)
        else
            fallback()
        end
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
                    require('luasnip').expand(args.body)
                end,
            },

            mapping = {
                ['<C-Space>'] = cmp.mapping.complete(),

                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-n>'] = cmp.mapping.select_next_item(),

                ['<C-k>'] = scroll_docs(-4),
                ['<C-j>'] = scroll_docs(4),

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
                { name = 'luasnip' },
                { name = 'path' },
            },
        }
    end,
}
