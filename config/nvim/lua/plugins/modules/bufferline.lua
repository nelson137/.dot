-- Fancy buffer line (instead of the default tab line)

vim.opt.termguicolors = true
vim.opt.mousemoveevent = true

local formatters = {
    -- Angular Modules
    { suffix = '.module.ts',         replacement = '[mod]' },
    { suffix = '.module.spec.ts',    replacement = '[mod]test' },
    { suffix = '.module.test.ts',    replacement = '[mod]test' },
    -- Angular Services
    { suffix = '.service.ts',        replacement = '[svc]' },
    { suffix = '.service.spec.ts',   replacement = '[svc]test' },
    { suffix = '.service.test.ts',   replacement = '[svc]test' },
    -- NgRx Store
    { suffix = '.selector.ts',       replacement = '[sel]' },
    { suffix = '.selector.spec.ts',  replacement = '[sel]test' },
    { suffix = '.selector.test.ts',  replacement = '[sel]test' },
    { suffix = '.reducer.ts',        replacement = '[red]' },
    { suffix = '.reducer.spec.ts',   replacement = '[red]test' },
    { suffix = '.reducer.test.ts',   replacement = '[red]test' },
    -- Angular Components
    { suffix = '.component.ts',      replacement = '[C]ts' },
    { suffix = '.component.html',    replacement = '[C]html' },
    { suffix = '.component.css',     replacement = '[C]css' },
    { suffix = '.component.scss',    replacement = '[C]scss' },
    { suffix = '.component.spec.ts', replacement = '[C]test' },
    { suffix = '.component.test.ts', replacement = '[C]test' },
}

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
                if infos and infos > 0 then table.insert(sections, infos .. '🛈 ') end
                return table.concat(sections, ' ')
            end,
            hover = {
                enabled = true,
                delay = 0,
                reveal = { 'close' },
            },
            left_trunc_marker = '⟵',
            max_name_length = 42,
            max_prefix_length = 16,
            name_formatter = function(buf)
                for _, f in pairs(formatters) do
                    if vim.endswith(buf.name, f.suffix) then
                        return string.sub(buf.name, 1, #buf.name - #f.suffix) .. f.replacement
                    end
                end
                return buf.name
            end,
            right_trunc_marker = '⟶',
            sort_by = 'insert_at_end',
        },
    },

    config = function(_, opts)
        local b = require('bufferline')

        b.setup(opts)

        vim.keymap.del('n', 'gh');
        vim.keymap.del('n', 'gl');
        Map('BufferLine', 'n', 'gh', function() b.cycle(-1) end, 'previous')
        Map('BufferLine', 'n', 'gl', function() b.cycle(1) end, 'next')
        Map('BufferLine', 'n', 'g,', function() b.move(-1) end, 'move previous')
        Map('BufferLine', 'n', 'g.', function() b.move(1) end, 'move next')
        Map('BufferLine', 'n', 'g<', function() b.move_to(1) end, 'move to start')
        Map('BufferLine', 'n', 'g>', function() b.move_to(-1) end, 'move to end')
    end,
}
