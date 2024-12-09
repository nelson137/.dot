-- Angular language server

local function opts(desc)
    return { desc = 'Angular: ' .. desc }
end

return {
    'joeveiga/ng.nvim',
    enabled = false,

    config = function()
        local ng = require('ng')
        vim.keymap.set('n', '<Leader>at', function ()
            ng.goto_template_for_component({ reuse_window = true })
        end, opts('go to component template'))
        vim.keymap.set('n', '<Leader>ac', function ()
            ng.goto_component_with_template_file({ reuse_window = true })
        end, opts('go to component with template file'))
        vim.keymap.set('n', '<Leader>aT', ng.get_template_tcb,
            opts('template type check block'))
    end,
}
