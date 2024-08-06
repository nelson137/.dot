-- Terminal window manager

---@return Terminal
local function create_lazy_git_term()
    local Terminal = require('toggleterm.terminal').Terminal
    return Terminal:new({
        display_name = 'lazygit',
        cmd = 'lazygit',
        direction = 'float',
        float_opts = { border = 'curved' },
    })
end

--- Get the singleton instance of the LazyGit terminal if it exists.
---
---@return Terminal|nil
local function find_lazy_git_term()
    local Terminal = require('toggleterm.terminal')
    return Terminal.find(
        function(term) return term:_display_name() == 'lazygit' end
    )
end

---Get the singleton instance of the LazyGit terminal.
---
---@return Terminal
local function get_lazy_git_term()
    return find_lazy_git_term() or create_lazy_git_term()
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
        local lazy_git_term = find_lazy_git_term()
        if lazy_git_term and lazy_git_term:is_open() then
            map('<F4>', toggle_lazy_git_term, 'lazy git')
        else
            -- map('<C-w>', [[<C-\><C-n>]], 'escape')
            map('<C-w>', [[<C-\><C-n><C-w>]], 'window command leader')
        end
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
