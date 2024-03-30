-- Text case converter utility

return {
    'johmsalas/text-case.nvim',

    dependencies = { "nvim-telescope/telescope.nvim" },

    config = function(_, opts)
        require('textcase').setup(opts)
        require('telescope').load_extension('textcase')
    end,
}
