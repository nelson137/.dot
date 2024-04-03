-- A diagnostic, reference, telescope result, etc. list

local function t() return require('trouble') end

local function t_toggle() t().toggle() end
local function t_close() t().close() end
local function t_toggle_ws() t().toggle('workspace_diagnostics') end
local function t_toggle_doc() t().toggle('document_diagnostics') end
local function t_toggle_refs() t().toggle('lsp_references') end

return {
    'folke/trouble.nvim',

    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },

    event = 'BufReadPre',

    keys = {
        { '<Leader>xx', t_toggle,      desc = 'Trouble: toggle' },
        { '<Leader>xc', t_close,       desc = 'Trouble: close' },
        { '<Leader>xd', t_toggle_doc,  desc = 'Trouble: toggle document diagnostics' },
        { '<Leader>xw', t_toggle_ws,   desc = 'Trouble: toggle workspace diagnostics' },
        { '<Leader>xr', t_toggle_refs, desc = 'Trouble: toggle LSP references' },
    },

    opts = {
        action_keys = {
            jump = { '<Tab>', '<2-LeftMouse>' },
            jump_close = { '<CR>', 'o' },
        },
        auto_open = false,
    },
}
