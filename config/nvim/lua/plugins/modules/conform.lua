return {
    'stevearc/conform.nvim',

    dependencies = { 'neovim/nvim-lspconfig' },

    opts = {
        default_format_opts = {
            lsp_format = 'fallback',
            timeout_ms = 4000,
        },
        formatters_by_ft = {
            javascript = { 'prettier' },
            lua = { 'stylua' },
            python = { 'ruff_format' },
            -- rust = { 'rustfmt' }, -- taken care of by rustaceanvim
            typescript = { 'prettier' },
            ['_'] = { 'trim_whitespace' },
        },
    },
}
