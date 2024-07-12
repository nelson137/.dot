---Create a keymap.
---@param label string The mapping label, or used as the description if `description` is `nil`.
---@param mode string|table Mode short-name, see |nvim_set_keymap()|.
---@param lhs string Left-hand |{lhs}| of the mapping.
---@param rhs string|function Right-hand |{rhs}| of the mapping, can be a Lua function.
---@param description string|nil Appended to `label` with `': '`, if given, for the description.
---@param other_opts table|nil Table of |:map-arguments|.
local function map(label, mode, lhs, rhs, description, other_opts)
    local desc = label
    if description then desc = desc .. ': ' .. description end
    local opts = vim.tbl_extend(
        'force',
        other_opts or {},
        { desc = desc }
    )
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- Space is |<Leader>|; remap to |<Nop>| since it behaves like |h|
map('Leader', { 'n', 'v' }, '<Space>', '<Nop>')

-- Jump to beginning/end of the current line
map('Jump', { 'n', 'v' }, 'H', '^',  'to the first non-blank character of the line')
map('Jump', { 'n', 'v' }, 'L', '$',  'to the end of the line')

-- TODO: Use sneak plugin for f and F
-- vim.keymap.set('n', '<Leader>f', '<Plug>Sneak_s', { desc = '' })
-- vim.keymap.set('n', '<Leader>F', '<Plug>Sneak_S', { desc = '' })

-- Disable highlight search
map('Disable hlsearch', 'n', '<C-n>', '<Cmd>nohlsearch<CR>')

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
map('Repeat last search', 'n', 'n', repeatSearch_Next, 'forward and flash the cursor line')
map('Repeat last search', 'n', 'N', repeatSearch_Prev, 'backward and flash the cursor line')

-- Better buffer control
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
map('Buffers', 'n', 'gl', '<Cmd>bn<CR>', 'next')
map('Buffers', 'n', 'gh', '<Cmd>bp<CR>', 'previous')
map('Buffers', 'n', 'gd', '<Cmd>bd<CR>', 'close')
map('Buffers', 'n', 'gDD', '<Cmd>%bd<CR>', 'close all')
map('Buffers', 'n', 'gDO', buf_close_others, 'close other')

-- Better tab control
map('Tabs', 'n', 'tn', '<Cmd>tabnew<CR>',      'new')
map('Tabs', 'n', 'td', '<Cmd>tabclose<CR>',    'new')
map('Tabs', 'n', 'th', '<Cmd>tabprevious<CR>', 'next')
map('Tabs', 'n', 'tl', '<Cmd>tabnext<CR>',     'previous')
map('Tabs', 'n', 'tH', '<Cmd>tabfirst<CR>',    'first')
map('Tabs', 'n', 'tL', '<Cmd>tablast<CR>',     'last')
map('Tabs', 'n', 'Th', '<Cmd>tabmove -<CR>',   'move left')
map('Tabs', 'n', 'Tl', '<Cmd>tabmove +<CR>',   'move right')
map('Tabs', 'n', 'TH', '<Cmd>tabmove 0<CR>',   'move to beginning')
map('Tabs', 'n', 'TL', '<Cmd>tabmove $<CR>',   'move to end')

-- Don't swap selection and register " when pasting
map('Paste and keep register', 'x', 'p', 'pgvy')

-- Paste in insert mode
map('Paste', 'i', '<C-p>', '<C-r>"', 'Paste')

-- Move lines up/down
--
-- Source: https://vim.fandom.com/wiki/Moving_lines_up_or_down#Mappings_to_move_lines
--
-- IDE Bindings:
--   * VS Code: <M-Up>
--   * Sublime Text: <C-S-Up>
map('Move Line', 'n', '<M-Down>',  '<Cmd>move  .+1<CR>',      'down')
map('Move Line', 'n', '<M-Up>',    '<Cmd>move  .-2<CR>',      'up'  )
map('Move Line', 'v', '<M-Down>',      ":move '>+1<CR>gv=gv", 'down')
map('Move Line', 'v', '<M-Up>',        ":move '<-2<CR>gv=gv", 'up'  )
map('Move Line', 'i', '<M-Down>', '<Esc>:move  .+1<CR>==gi',  'down')
map('Move Line', 'i', '<M-Up>',   '<Esc>:move  .-2<CR>==gi',  'up'  )

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
map('Move Line', 'n', '<M-Right>', '<Cmd>><CR>',      'right one `shiftwidth` level')
map('Move Line', 'n', '<M-Left>',  '<Cmd><<CR>',      'left one `shiftwidth` level' )
map('Move Line', 'v', '<M-Right>',     ':><CR>gv^',   'right one `shiftwidth` level')
map('Move Line', 'v', '<M-Left>',      ':<<CR>gv^',   'left one `shiftwidth` level' )
map('Move Line', 'i', '<M-Right>', insert_move_right, 'right one `shiftwidth` level')
map('Move Line', 'i', '<M-Left>',  insert_move_left,  'left one `shiftwidth` level')
