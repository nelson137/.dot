return {
    'stevearc/conform.nvim',

    dependencies = { 'neovim/nvim-lspconfig' },

    opts = {
        default_format_opts = {
            lsp_format = 'fallback',
            timeout_ms = 4000,
        },
        formatters_by_ft = {
            css = { 'prettier' },
            html = { 'prettier' },
            htmlangular = { 'prettier' },
            javascript = { 'prettier' },
            json = { 'prettier' },
            json5 = { 'prettier' },
            lua = { 'stylua' },
            python = { 'ruff_format' },
            rust = { 'rustfmt' },
            svelte = { 'prettier' },
            typescript = { 'prettier' },
            ['_'] = { 'trim_newlines', 'trim_whitespace' },
        },
    },
}
