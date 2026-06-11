-- Fancy buffer line (instead of the default tab line)

vim.opt.termguicolors = true
vim.opt.mousemoveevent = true

local formatters = {
    -- Angular Modules
    { suffix = '.module.ts',               replacement = '[M]' },
    { suffix = '.module.spec.ts',          replacement = '[M/test]' },
    { suffix = '.module.test.ts',          replacement = '[M/test]' },
    -- Angular Services
    { suffix = '.service.ts',              replacement = '[svc]' },
    { suffix = '.service.spec.ts',         replacement = '[svc/test]' },
    { suffix = '.service.test.ts',         replacement = '[svc/test]' },
    -- Angular Components
    { suffix = '.component.ts',            replacement = '[C]' },
    { suffix = '.component.html',          replacement = '[C]html' },
    { suffix = '.component.css',           replacement = '[C]css' },
    { suffix = '.component.scss',          replacement = '[C]scss' },
    { suffix = '.component.spec.ts',       replacement = '[C/test]' },
    { suffix = '.component.test.ts',       replacement = '[C/test]' },
    -- NgRx Store
    { suffix = '.actions.ts',              replacement = '[act]' },
    { suffix = '.events.ts',               replacement = '[evt]' },
    { suffix = '.selectors.ts',            replacement = '[sel]' },
    { suffix = '.selectors.spec.ts',       replacement = '[sel/test]' },
    { suffix = '.selectors.test.ts',       replacement = '[sel/test]' },
    { suffix = '.reducer.ts',              replacement = '[red]' },
    { suffix = '.reducer.spec.ts',         replacement = '[red/test]' },
    { suffix = '.reducer.test.ts',         replacement = '[red/test]' },
    { suffix = '.effects.ts',              replacement = '[eff]' },
    { suffix = '.effects.spec.ts',         replacement = '[eff/test]' },
    { suffix = '.effects.test.ts',         replacement = '[eff/test]' },
    { suffix = '.store.ts',                replacement = '[store]' },
    { suffix = '.store.spec.ts',           replacement = '[store/test]' },
    { suffix = '.store.test.ts',           replacement = '[store/test]' },
    { suffix = '.signal-store.ts',         replacement = '[store]' },
    { suffix = '.signal-store.spec.ts',    replacement = '[store/test]' },
    { suffix = '.signal-store.test.ts',    replacement = '[store/test]' },
    { suffix = '.component-store.ts',      replacement = '[store]' },
    { suffix = '.component-store.spec.ts', replacement = '[store/test]' },
    { suffix = '.component-store.test.ts', replacement = '[store/test]' },
}

return {
    pack = {
        src = { github = 'akinsho/bufferline.nvim' },
    },

    spec = {
        'bufferline.nvim',

        lazy = false,

        after = function()
            ---@module 'bufferline'
            ---@type bufferline.UserConfig
            local opts = {
                options = {
                    diagnostics = 'nvim_lsp',
                    diagnostics_indicator = function(_, _, diagnostics_dict)
                        local errors = diagnostics_dict['error']
                        local warnings = diagnostics_dict['warning']
                        local infos = diagnostics_dict['info']
                        local sections = {}
                        if errors and errors > 0 then table.insert(sections, errors .. '') end
                        if warnings and warnings > 0 then table.insert(sections, warnings .. '') end
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
                    ---@param buf BufferLineTab
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
            }

            local b = require('bufferline')

            b.setup(opts)

            vim.keymap.del('n', 'gh');
            vim.keymap.del('n', 'gl');

            local map = Map('BufferLine')
            map('n', 'gh', function() b.cycle(-1) end, 'previous')
            map('n', 'gl', function() b.cycle(1) end, 'next')
            map('n', 'g,', function() b.move(-1) end, 'move previous')
            map('n', 'g.', function() b.move(1) end, 'move next')
            map('n', 'g<', function() b.move_to(1) end, 'move to start')
            map('n', 'g>', function() b.move_to(-1) end, 'move to end')
        end,
    },
}
