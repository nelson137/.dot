local function create_keymapper(label, mode)
    return function(lhs, rhs, desc)
        local opts = { desc = label .. ': ' .. desc }
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

-- Space is `<Leader>`, unmap it's alias to `h`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

-- H and L go to the beginning and end of the line
vim.keymap.set({ 'n', 'v' }, 'H', '^', { desc = 'To the first non-blank character of the line' })
vim.keymap.set({ 'n', 'v' }, 'J', 'G', { desc = 'To the last line' })
vim.keymap.set({ 'n', 'v' }, 'K', 'gg', { desc = 'To the first line' })
vim.keymap.set({ 'n', 'v' }, 'L', '$', { desc = 'To the end of the line' })

vim.keymap.set({ 'n', 'v' }, '<C-j>', 'J', { desc = 'Join lines' })

-- TODO: Use sneak plugin for f and F
-- vim.keymap.set('n', '<Leader>f', '<Plug>Sneak_s', { desc = '' })
-- vim.keymap.set('n', '<Leader>F', '<Plug>Sneak_S', { desc = '' })

-- Disable highlight search
vim.keymap.set('n', '<C-n>', '<Cmd>nohlsearch<CR>', { silent = true, desc = '' })

-- Flash the cursorline when selecting the next/prev search match
local repeatSearch = function(direction_cmd)
    local status, _ = pcall(function() vim.cmd('normal! ' .. direction_cmd) end)
    if status then
        vim.api.nvim_exec2([[
            set cursorline!
            redraw
            exec 'sleep ' . float2nr(200) . 'm'
            set cursorline!
            redraw
        ]], {})
    end
end
local repeatSearch_Next = function() repeatSearch('n') end
local repeatSearch_Prev = function() repeatSearch('N') end
vim.keymap.set('n', 'n', repeatSearch_Next, { silent = true, desc = 'Repeat the last search and flash the cursor line' })
vim.keymap.set('n', 'N', repeatSearch_Prev,
    { silent = true, desc = 'Repeat the last search in the opposite direction and flash the cursor line' })

-- Better buffer control
local buf_keymapper = create_keymapper('Buffers', 'n')
local function buf_close_others()
    local curr_bufnr = vim.api.nvim_get_current_buf()
    vim.cmd.bwipeout(vim.tbl_filter(
        function(bufnr)
            return vim.fn.buflisted(bufnr) and bufnr ~= curr_bufnr
        end,
        vim.api.nvim_list_bufs()
    ))
    vim.cmd.redrawtabline()
end
buf_keymapper('gl', '<Cmd>bn<CR>', 'next')
buf_keymapper('gh', '<Cmd>bp<CR>', 'previous')
buf_keymapper('gd', '<Cmd>bd<CR>', 'close')
buf_keymapper('gDD', '<Cmd>%bd<CR>', 'close all')
buf_keymapper('gDO', buf_close_others, 'close other')

-- Better tab control
local tab_keymapper = create_keymapper('Tabs', 'n')
tab_keymapper('tn', '<Cmd>tabnew<CR>', 'new')
tab_keymapper('td', '<Cmd>tabclose<CR>', 'new')
tab_keymapper('th', '<Cmd>tabprevious<CR>', 'next')
tab_keymapper('tl', '<Cmd>tabnext<CR>', 'previous')
tab_keymapper('tH', '<Cmd>tabfirst<CR>', 'first')
tab_keymapper('tL', '<Cmd>tablast<CR>', 'last')
tab_keymapper('Th', '<Cmd>tabmove -<CR>', 'move left')
tab_keymapper('Tl', '<Cmd>tabmove +<CR>', 'move right')
tab_keymapper('TH', '<Cmd>tabmove 0<CR>', 'move to beginning')
tab_keymapper('TL', '<Cmd>tabmove $<CR>', 'move to end')

-- Don't swap selection and register " when pasting
vim.keymap.set('x', 'p', 'pgvy')

-- Paste in insert mode
vim.keymap.set('i', '<C-p>', '<C-r>"', { desc = 'Paste' })
