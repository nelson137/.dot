-- crates.io completions

return {
    pack = {
        src = { github = 'saecki/crates.nvim' },
        version = 'stable',
    },

    spec = {
        'crates.nvim',

        event = { event = 'BufRead', pattern = 'Cargo.toml' },

        after = function()
            ---@module 'crates'
            ---@type crates.UserConfig
            local opts = {
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
            }

            require('crates').setup(opts)
        end,
    },
}
