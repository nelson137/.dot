-- Space is |<Leader>|; remap to |<Nop>| since it behaves like |h|
Map('Leader')({ 'n', 'v' }, '<Space>', '<Nop>')

-- Jump to beginning/end of the current line
local jump_map = Map('Jump')
jump_map({ 'n', 'v' }, 'H', '^', 'to the first non-blank character of the line')
jump_map({ 'n', 'v' }, 'L', '$', 'to the end of the line')

-- TODO: Use sneak plugin for f and F
-- vim.keymap.set('n', '<Leader>f', '<Plug>Sneak_s', { desc = '' })
-- vim.keymap.set('n', '<Leader>F', '<Plug>Sneak_S', { desc = '' })

-- Disable highlight search
Map('Disable hlsearch')('n', '<C-n>', '<Cmd>nohlsearch<CR>')

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
local search_map = Map('Search')
search_map('n', 'n', repeatSearch_Next, 'repeat forward and flash the cursor line')
search_map('n', 'N', repeatSearch_Prev, 'repeat backward and flash the cursor line')

-- Better buffer control
local buf_map = Map('Buffers')
buf_map('n', 'gl', '<Cmd>bn<CR>', 'next')
buf_map('n', 'gh', '<Cmd>bp<CR>', 'previous')
buf_map('n', 'gd', function() Snacks.bufdelete.delete() end, 'close current')
buf_map('n', 'gDD', function() Snacks.bufdelete.all() end, 'close all')
buf_map('n', 'gDO', function() Snacks.bufdelete.other() end, 'close other')

-- Better tab control
local tab_map = Map('Tabs')
tab_map('n', 'tn', '<Cmd>tabnew<CR>', 'new')
tab_map('n', 'td', '<Cmd>tabclose<CR>', 'new')
tab_map('n', 'th', '<Cmd>tabprevious<CR>', 'next')
tab_map('n', 'tl', '<Cmd>tabnext<CR>', 'previous')
tab_map('n', 'tH', '<Cmd>tabfirst<CR>', 'first')
tab_map('n', 'tL', '<Cmd>tablast<CR>', 'last')
tab_map('n', 'Th', '<Cmd>tabmove -<CR>', 'move left')
tab_map('n', 'Tl', '<Cmd>tabmove +<CR>', 'move right')
tab_map('n', 'TH', '<Cmd>tabmove 0<CR>', 'move to beginning')
tab_map('n', 'TL', '<Cmd>tabmove $<CR>', 'move to end')

-- Don't swap selection and register " when pasting
Map('Paste and keep register')('x', 'p', 'pgvy')

-- Paste in insert mode
Map('Paste')('i', '<C-p>', '<C-r>"', 'Paste')

-- Move lines up/down
--
-- Source: https://vim.fandom.com/wiki/Moving_lines_up_or_down#Mappings_to_move_lines
--
-- IDE Bindings:
--   * VS Code: <M-Up>
--   * Sublime Text: <C-S-Up>
local move_line_map = Map('Move Line')
move_line_map('n', '<M-Down>', '<Cmd>move  .+1<CR>', 'down')
move_line_map('n', '<M-Up>', '<Cmd>move  .-2<CR>', 'up')
move_line_map('v', '<M-Down>', ":move '>+1<CR>gv=gv", 'down')
move_line_map('v', '<M-Up>', ":move '<-2<CR>gv=gv", 'up')
move_line_map('i', '<M-Down>', '<Esc>:move  .+1<CR>==gi', 'down')
move_line_map('i', '<M-Up>', '<Esc>:move  .-2<CR>==gi', 'up')

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
move_line_map('n', '<M-Right>', '<Cmd>><CR>', 'right one `shiftwidth` level')
move_line_map('n', '<M-Left>', '<Cmd><<CR>', 'left one `shiftwidth` level')
move_line_map('v', '<M-Right>', ':><CR>gv^', 'right one `shiftwidth` level')
move_line_map('v', '<M-Left>', ':<<CR>gv^', 'left one `shiftwidth` level')
move_line_map('i', '<M-Right>', insert_move_right, 'right one `shiftwidth` level')
move_line_map('i', '<M-Left>', insert_move_left, 'left one `shiftwidth` level')
