-- Terminal window manager

---@type Terminal|nil
local _lazy_git_term = nil

---Get the singleton instance of the LazyGit terminal.
---
---@return Terminal
local function get_lazy_git_term()
    if not _lazy_git_term then
        local Terminal = require('toggleterm.terminal').Terminal
        _lazy_git_term = Terminal:new({
            cmd = 'lazygit',
            direction = 'float',
            float_opts = { border = 'curved' },
            on_exit = function() _lazy_git_term = nil end
        })
    end
    return _lazy_git_term
end

-- Open a custom terminal with lazy git
local function toggle_lazy_git_term() get_lazy_git_term():toggle() end

-- Set keymaps on terminal open
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
    group = vim.api.nvim_create_augroup('SetTerminalKeymaps', {}),
    pattern = { 'term://*' },
    callback = function()
        local function map(lhs, rhs, desc)
            local opts = { buffer = 0, desc = 'ToggleTerm: ' .. desc }
            vim.keymap.set('t', lhs, rhs, opts)
        end
        -- map('<Esc>', [[<C-\><C-n>]], 'escape')
        map('<C-w>', [[<C-\><C-n><C-w>]], 'window command leader')
        map('<F4>', toggle_lazy_git_term, 'lazy git')
    end,
})

return {
    'akinsho/toggleterm.nvim',

    keys = {
        {
            '<Leader>tt',
            '<Cmd>ToggleTerm direction=horizontal<CR>',
            desc = 'ToggleTerm: new',
        },
        {
            '<Leader>tf',
            '<Cmd>ToggleTerm direction=float<CR>',
            desc = 'ToggleTerm: floating',
        },
        {
            '<F4>',
            toggle_lazy_git_term,
            desc = 'ToggleTerm: lazy git',
        },
        {
            '<Leader>ts',
            '<Cmd>ToggleTermSendVisualSelection<CR>',
            mode = 'v',
            desc = 'ToggleTerm: send visual selection',
        },
        {
            '<Leader>tl',
            '<Cmd>ToggleTermSendVisualLines<CR>',
            mode = 'v',
            desc = 'ToggleTerm: send visual lines',
        },
    },

    opts = {
        on_create = function()
            vim.env.NO_STARSHIP = '1'
        end,
    },

    config = function(_, opts)
        require('toggleterm').setup(opts)
    end,
}
