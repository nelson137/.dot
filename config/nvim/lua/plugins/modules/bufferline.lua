-- Fancy buffer line (instead of the default tab line)

vim.opt.termguicolors = true
vim.opt.mousemoveevent = true

return {
    'akinsho/bufferline.nvim',

    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },

    opts = {
        options = {
            diagnostics = 'nvim_lsp',
            diagnostics_indicator = function(_, _, diagnostics_dict)
                local errors = diagnostics_dict['error']
                local warnings = diagnostics_dict['warning']
                local infos = diagnostics_dict['info']
                local sections = {}
                if errors and errors > 0 then table.insert(sections, errors .. '') end
                if warnings and warnings > 0 then table.insert(sections, warnings .. '') end
                if infos and infos > 0 then table.insert(sections, infos .. '') end
                return table.concat(sections, ' ')
            end,
            hover = {
                enabled = true,
                delay = 0,
                reveal = { 'close' },
            },
            left_trunc_marker = '⟵',
            right_trunc_marker = '⟶',
            sort_by = 'insert_at_end',
        },
    },
}




