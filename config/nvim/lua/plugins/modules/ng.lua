-- Angular language server

return {
    'joeveiga/ng.nvim',

    config = function()
        local ng = require('ng')

        local map = Map('Angular')

        local function goto_component()
            ng.goto_component_with_template_file({ reuse_window = true })
        end

        local function goto_template()
            ng.goto_template_for_component({ reuse_window = true })
        end

        map('n', '<Leader>at', goto_template, 'go to component template')
        map('n', '<Leader>ac', goto_component, 'go to component')
        map('n', '<Leader>aT', ng.get_template_tcb, 'template type check block')
    end,
}
