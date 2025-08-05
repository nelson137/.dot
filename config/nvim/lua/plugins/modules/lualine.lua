-- Fancy status line

return {
    'nvim-lualine/lualine.nvim',

    -- Sections:
    -- +-------------------------------------------------+
    -- | A | B | C                             X | Y | Z |
    -- +-------------------------------------------------+
    opts = {
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
    },
}
