-- Debug Adapter Protocol

local P = {
    ---@type (fun(): table)|(fun(callback: fun(ui: table)): fun())
    ui = function(callback)
        local ui = require('dap.ui.widgets')
        if callback ~= nil then
            return function() callback(ui) end
        else
            return ui
        end
    end,
}
setmetatable(P, {
    __call = function() return require('dap') end,
})

return {
    'mfussenegger/nvim-dap',

    config = function()
        local dap = require('dap')
        dap.defaults.fallback.terminal_win_cmd = 'tabnew'

        Map('DAP', { 'n' }, '<F5>', function() P().continue() end, 'continue')
        Map('DAP', { 'n' }, '<Leader>lt', function() P().terminate() end, 'terminate')
        Map('DAP', { 'n' }, '<Leader>ll', function() P().step_over() end, 'step over')
        Map('DAP', { 'n' }, '<Leader>lj', function() P().step_into() end, 'step into')
        Map('DAP', { 'n' }, '<Leader>lk', function() P().step_out() end, 'step out')
        Map('DAP', { 'n' }, '<Leader>b', function() P().toggle_breakpoint() end, 'toggle breakpoint')
        Map('DAP', { 'n' }, '<Leader>lB', function() P().clear_breakpoints() end, 'clear breakpoints')
        Map('DAP', { 'n' }, '<Leader>lp', function() P().set_breakpoint(nil, nil, vim.fn.input('Log point: ')) end,
            'set log point')
        Map('DAP', { 'n' }, '<Leader>lr', function() P().repl.open() end, 'open REPL')
        Map('DAP', { 'n', 'v' }, '<Leader>lk', function() P.ui().hover() end, 'hover')
        Map('DAP', { 'n', 'v' }, '<Leader>lp', function() P.ui().preview() end, 'preview')
        Map('DAP', { 'n', 'v' }, '<Leader>lf', P.ui(function(ui) ui.centered_float(ui.frames) end), 'frames')
        Map('DAP', { 'n', 'v' }, '<Leader>ls', P.ui(function(ui) ui.centered_float(ui.scopes) end), 'scopes')

        vim.api.nvim_create_autocmd({ 'FileType' }, {
            group = vim.api.nvim_create_augroup('Ft_dap_float', {}),
            pattern = { 'dap-float' },
            callback = function()
                Map('DAP', 'n', 'q', '<C-w>c', 'close float')
            end,
        })
    end
}
