-- Fancy status line

return {
    pack = {
        src = { github = 'nvim-lualine/lualine.nvim' },
    },

    spec = {
        'lualine.nvim',

        event = 'DeferredUIEnter',

        after = function()
            -- Sections:
            -- +-------------------------------------------------+
            -- | A | B | C                             X | Y | Z |
            -- +-------------------------------------------------+
            require('lualine').setup({
                options = {
                    disabled_filetypes = {
                        statusline = { 'neo-tree', 'dapui_scopes', 'dapui_breakpoints', 'dapui_stacks', 'dapui_watches', 'dapui_console', 'dap-repl' },
                    },
                },

                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diagnostics' },
                    lualine_x = { 'filetype', 'fileformat' },
                },
            })
        end,
    },
}
