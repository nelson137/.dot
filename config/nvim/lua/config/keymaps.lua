-- Space is |<Leader>|; remap to |<Nop>| since it behaves like |h|
Map('Leader', { 'n', 'v' }, '<Space>', '<Nop>')

-- Jump to beginning/end of the current line
Map('Jump', { 'n', 'v' }, 'H', '^', 'to the first non-blank character of the line')
Map('Jump', { 'n', 'v' }, 'L', '$', 'to the end of the line')

-- TODO: Use sneak plugin for f and F
-- vim.keymap.set('n', '<Leader>f', '<Plug>Sneak_s', { desc = '' })
-- vim.keymap.set('n', '<Leader>F', '<Plug>Sneak_S', { desc = '' })

-- Disable highlight search
Map('Disable hlsearch', 'n', '<C-n>', '<Cmd>nohlsearch<CR>')

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
Map('Repeat last search', 'n', 'n', repeatSearch_Next, 'forward and flash the cursor line')
Map('Repeat last search', 'n', 'N', repeatSearch_Prev, 'backward and flash the cursor line')

-- Better buffer control
Map('Buffers', 'n', 'gl', '<Cmd>bn<CR>', 'next')
Map('Buffers', 'n', 'gh', '<Cmd>bp<CR>', 'previous')
Map('Buffers', 'n', 'gd', function() Snacks.bufdelete.delete() end, 'close current')
Map('Buffers', 'n', 'gDD', function() Snacks.bufdelete.all() end, 'close all')
Map('Buffers', 'n', 'gDO', function() Snacks.bufdelete.other() end, 'close other')

-- Better tab control
Map('Tabs', 'n', 'tn', '<Cmd>tabnew<CR>', 'new')
Map('Tabs', 'n', 'td', '<Cmd>tabclose<CR>', 'new')
Map('Tabs', 'n', 'th', '<Cmd>tabprevious<CR>', 'next')
Map('Tabs', 'n', 'tl', '<Cmd>tabnext<CR>', 'previous')
Map('Tabs', 'n', 'tH', '<Cmd>tabfirst<CR>', 'first')
Map('Tabs', 'n', 'tL', '<Cmd>tablast<CR>', 'last')
Map('Tabs', 'n', 'Th', '<Cmd>tabmove -<CR>', 'move left')
Map('Tabs', 'n', 'Tl', '<Cmd>tabmove +<CR>', 'move right')
Map('Tabs', 'n', 'TH', '<Cmd>tabmove 0<CR>', 'move to beginning')
Map('Tabs', 'n', 'TL', '<Cmd>tabmove $<CR>', 'move to end')

-- Don't swap selection and register " when pasting
Map('Paste and keep register', 'x', 'p', 'pgvy')

-- Paste in insert mode
Map('Paste', 'i', '<C-p>', '<C-r>"', 'Paste')

-- Move lines up/down
--
-- Source: https://vim.fandom.com/wiki/Moving_lines_up_or_down#Mappings_to_move_lines
--
-- IDE Bindings:
--   * VS Code: <M-Up>
--   * Sublime Text: <C-S-Up>
Map('Move Line', 'n', '<M-Down>', '<Cmd>move  .+1<CR>', 'down')
Map('Move Line', 'n', '<M-Up>', '<Cmd>move  .-2<CR>', 'up')
Map('Move Line', 'v', '<M-Down>', ":move '>+1<CR>gv=gv", 'down')
Map('Move Line', 'v', '<M-Up>', ":move '<-2<CR>gv=gv", 'up')
Map('Move Line', 'i', '<M-Down>', '<Esc>:move  .+1<CR>==gi', 'down')
Map('Move Line', 'i', '<M-Up>', '<Esc>:move  .-2<CR>==gi', 'up')

local function insert_move_right()
    local shift = vim.o.shiftwidth
    local offset_cmd = string.rep('<Right>', (shift or 0))
    local keys = vim.api.nvim_replace_termcodes('<Esc>' .. ':><CR>gi' .. offset_cmd, true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)
end
local function insert_move_left()
    local shift = vim.o.shiftwidth
    local offset_cmd = string.rep('<Left>', (shift or 0))
    local keys = vim.api.nvim_replace_termcodes(offset_cmd .. '<Esc>' .. ':<<CR>gi', true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)
end
Map('Move Line', 'n', '<M-Right>', '<Cmd>><CR>', 'right one `shiftwidth` level')
Map('Move Line', 'n', '<M-Left>', '<Cmd><<CR>', 'left one `shiftwidth` level')
Map('Move Line', 'v', '<M-Right>', ':><CR>gv^', 'right one `shiftwidth` level')
Map('Move Line', 'v', '<M-Left>', ':<<CR>gv^', 'left one `shiftwidth` level')
Map('Move Line', 'i', '<M-Right>', insert_move_right, 'right one `shiftwidth` level')
Map('Move Line', 'i', '<M-Left>', insert_move_left, 'left one `shiftwidth` level')
