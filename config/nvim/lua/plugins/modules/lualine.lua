-- Fancy status line

return {
    'nvim-lualine/lualine.nvim',

    -- Sections:
    -- +-------------------------------------------------+
    -- | A | B | C                             X | Y | Z |
    -- +-------------------------------------------------+
    opts = {
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diagnostics' },
            lualine_x = { 'filetype', 'fileformat' },
        },
    },
}
