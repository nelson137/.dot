-- crates.io completions

return {
    'saecki/crates.nvim',

    tag = 'stable',

    event = { 'BufRead Cargo.toml' },

    opts = {
        lsp = {
            enabled = true,
            actions = true,
            completion = true,
            hover = true,
            on_attach = function(_, bufnr)
                local keyopts = { buffer = bufnr }
                Map(
                    'LSP',
                    { 'n', 'v' }, '<Leader>.', vim.lsp.buf.code_action,
                    'code action',
                    keyopts
                )
                Map(
                    'LSP',
                    'n', '<Leader>k', vim.lsp.buf.hover,
                    'hover',
                    keyopts
                )
            end,
        },
    },
}
