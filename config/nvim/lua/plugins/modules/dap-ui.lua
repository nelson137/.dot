local function P() return require('dapui') end

local function dapui_open()
    -- vim.cmd('tab split')
    P().open()
end

local function dapui_close()
    P().close()
    -- vim.cmd('tabclose')
end

local function dapui_toggle() P().toggle() end
local function dapui_eval() P().eval() end

vim.pack.add({
    { src = 'https://github.com/nvim-neotest/nvim-nio' }
}, { load = function() end })

return {
    pack = {
        src = { github = 'rcarriga/nvim-dap-ui' },
    },

    spec = {
        'nvim-dap-ui',

        -- Loaded by nvim-dap (so its listeners register), or directly via these keys.
        keys = {
            { '<Leader>LL', desc = 'DAP UI: toggle UI' },
            { '<M-k>',      mode = 'v',                desc = 'DAP UI: eval selection' },
        },

        before = function()
            vim.cmd.packadd('nvim-nio')
            require('lz.n').trigger_load('nvim-dap')
        end,

        after = function()
            P().setup()

            local dap = require('dap')

            dap.listeners.before.attach.dapui = dapui_open
            dap.listeners.before.launch.dapui = dapui_open
            -- dap.listeners.before.event_terminated.dapui = dapui_close
            dap.listeners.before.event_exited.dapui = dapui_close

            Map('DAP UI')('v', '<M-k>', dapui_eval, 'eval selection')
            Map('DAP UI')('n', '<Leader>LL', dapui_toggle, 'toggle UI')
        end,
    },
}
