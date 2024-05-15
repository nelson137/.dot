-- Fancy status line

return {
    'nvim-lualine/lualine.nvim',

    opts = {
        sections = {
            -- Sections:
            -- +-------------------------------------------------+
            -- | A | B | C                             X | Y | Z |
            -- +-------------------------------------------------+
            lualine_b = { 'branch', 'diagnostics' },
            lualine_x = { 'filetype', 'fileformat' },
        },
    },
}
