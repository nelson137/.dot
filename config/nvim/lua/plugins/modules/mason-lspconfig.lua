-- Mason compatibility with lspconfig

return {
    'williamboman/mason-lspconfig',

    event = { 'BufReadPre', 'BufNewFile' },

    dependencies = { 'williamboman/mason.nvim' },

    opts = {
        ensure_installed = {
            'angularls@15.2.0',
            'eslint',
            'lua_ls',
            'rust_analyzer',
        },

        handlers = {
            function(server)
                require('lspconfig')[server].setup({})
            end,
            ['angularls'] = function()
                local util = require('lspconfig.util')

                local get_probe_dir = function(root_dir)
                    local project_root = util.find_node_modules_ancestor(root_dir)
                    return project_root and (project_root .. '/node_modules') or ''
                end

                local default_probe_dir = get_probe_dir(vim.fn.getcwd())

                require('lspconfig')['angularls'].setup({
                    cmd = {
                        'ngserver',
                        '--stdio',
                        '--tsProbeLocations', default_probe_dir,
                        '--ngProbeLocations', default_probe_dir,
                    },
                    root_dir = util.root_pattern('angular.json', 'nx.json'),
                    on_new_config = function(new_config, new_root_dir)
                        local new_probe_dir = get_probe_dir(new_root_dir)
                        new_config.cmd = {
                            'ngserver',
                            '--stdio',
                            '--tsProbeLocations', new_probe_dir,
                            '--ngProbeLocations', new_probe_dir,
                        }
                    end,
                })
            end,
            ['rust_analyzer'] = function()
                -- noop
            end,
        },
    },
}
