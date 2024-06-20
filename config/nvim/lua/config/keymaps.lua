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

-- Move lines up/down
--
-- Source: https://vim.fandom.com/wiki/Moving_lines_up_or_down#Mappings_to_move_lines
--
-- IDE Bindings:
--   * VS Code: <M-Up>
--   * Sublime Text: <C-S-Up>
vim.keymap.set('n', '<M-Down>', '<Cmd>move .+1<CR>',      { desc = 'Move Line: down' })
vim.keymap.set('n', '<M-Up>',   '<Cmd>move .-2<CR>',      { desc = 'Move Line: up'   })
vim.keymap.set('v', '<M-Down>', ":move '>+1<CR>gv=gv",    { desc = 'Move Line: down' })
vim.keymap.set('v', '<M-Up>',   ":move '<-2<CR>gv=gv",    { desc = 'Move Line: up'   })
vim.keymap.set('i', '<M-Down>', '<Esc>:move .+1<CR>==gi', { desc = 'Move Line: down' })
vim.keymap.set('i', '<M-Up>',   '<Esc>:move .-2<CR>==gi', { desc = 'Move Line: up'   })

vim.keymap.set('n', '<M-Right>', '<Cmd>><CR>', { desc = 'Move Line: right one `shiftwidth` level' })
vim.keymap.set('n', '<M-Left>',  '<Cmd><<CR>', { desc = 'Move Line: left one `shiftwidth` level'  })
vim.keymap.set('v', '<M-Right>', ':><CR>gv^',  { desc = 'Move Line: right one `shiftwidth` level' })
vim.keymap.set('v', '<M-Left>',  ':<<CR>gv^',  { desc = 'Move Line: left one `shiftwidth` level'  })
vim.keymap.set(
    'i',
    '<M-Right>',
    function()
        local shift = vim.o.shiftwidth
        local offset_cmd = string.rep('<Right>', (shift or 0))
        local keys = vim.api.nvim_replace_termcodes('<Esc>' .. ':><CR>gi' .. offset_cmd, true, false, true)
        vim.api.nvim_feedkeys(keys, 'n', false)
    end,
    { desc = 'Move Line: right one `shiftwidth` level' }
)
vim.keymap.set(
    'i',
    '<M-Left>',
    function()
        local shift = vim.o.shiftwidth
        local offset_cmd = string.rep('<Left>', (shift or 0))
        local keys = vim.api.nvim_replace_termcodes(offset_cmd .. '<Esc>' .. ':<<CR>gi', true, false, true)
        vim.api.nvim_feedkeys(keys, 'n', false)
    end,
    { desc = 'Move Line: left one `shiftwidth` level' }
)
