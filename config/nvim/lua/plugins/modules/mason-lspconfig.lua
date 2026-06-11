-- Mason compatibility with lspconfig

return {
    pack = {
        src = { github = 'mason-org/mason-lspconfig.nvim' },
    },

    spec = {
        'mason-lspconfig.nvim',

        event = { 'BufReadPre', 'BufNewFile' },

        before = function()
            require('lz.n').trigger_load('mason.nvim')
        end,

        after = function()
            ---@module 'mason-lspconfig'
            ---@type MasonLspconfigSettings
            local opts = {
                automatic_enable = {
                    exclude = {
                        'rust_analyzer',
                        'ts_ls',
                    },
                },

                ensure_installed = {
                    'angularls',
                    'basedpyright',
                    'eslint',
                    'lua_ls',
                    -- 'netcoredbg', -- Mason can't install packages from 3rd-party registries
                    -- 'roslyn', -- Mason can't install packages from 3rd-party registries
                    'rust_analyzer',
                    'ts_ls',
                },
            }

            require('mason-lspconfig').setup(opts)
        end,
    },
}
