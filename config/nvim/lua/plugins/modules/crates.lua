-- crates.io completions

return {
    'saecki/crates.nvim',

    tag = 'stable',

    event = { 'BufRead Cargo.toml' },

    ---@module 'crates'
    ---@type crates.UserConfig
    opts = {
        lsp = {
            enabled = true,
            actions = true,
            completion = true,
            hover = true,
            on_attach = function(_, bufnr)
                local map = Map('LSP', { buffer = bufnr })
                map({ 'n', 'v' }, '<Leader>.', vim.lsp.buf.code_action, 'code action')
                map({ 'n' }, '<Leader>k', vim.lsp.buf.hover, 'hover')
            end,
        },
    },
}
