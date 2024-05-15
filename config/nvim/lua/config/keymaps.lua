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
vim.keymap.set('n', '<C-n>', ':nohlsearch<CR>', { silent = true, desc = '' })

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
vim.keymap.set('n', 'gl', ':bn<CR>', { silent = true, desc = 'Next buffer' })
vim.keymap.set('n', 'gh', ':bp<CR>', { silent = true, desc = 'Previous buffer' })
vim.keymap.set('n', 'gd', ':bd<CR>', { silent = true, desc = 'Close buffer' })
vim.keymap.set('n', 'gDD', ':%bd<CR>', { silent = true, desc = 'Close all buffers' })
vim.keymap.set('n', 'gDO', function ()
    local curr_bufnr = vim.fn.bufnr()
    local to_delete = {}
    for _, n in ipairs(vim.api.nvim_list_bufs()) do
        if n ~= curr_bufnr and vim.fn.buflisted(n) then
            table.insert(to_delete, n)
        end
    end
    vim.cmd.bdelete(to_delete)
    vim.cmd.redrawtabline()
end, { silent = true, desc = 'Close other buffers' })

-- Better tab control
vim.keymap.set('n', 'tn', ':tabnew<CR>', { desc = 'New tab' })
vim.keymap.set('n', 'td', ':tabclose<CR>', { desc = 'New tab' })
vim.keymap.set('n', 'th', ':tabprevious<CR>', { desc = 'Next tab' })
vim.keymap.set('n', 'tl', ':tabnext<CR>', { desc = 'Previous tab' })
vim.keymap.set('n', 'tH', ':tabfirst<CR>', { desc = 'First tab' })
vim.keymap.set('n', 'tL', ':tablast<CR>', { desc = 'Last tab' })
vim.keymap.set('n', 'Th', ':tabmove -<CR>', { desc = 'Move tab left' })
vim.keymap.set('n', 'Tl', ':tabmove +<CR>', { desc = 'Move tab right' })
vim.keymap.set('n', 'TH', ':tabmove 0<CR>', { desc = 'Move tab to beginning' })
vim.keymap.set('n', 'TL', ':tabmove $<CR>', { desc = 'Move tab to end' })

-- Don't swap selection and register " when pasting
vim.keymap.set('x', 'p', 'pgvy')

-- Paste in insert mode
vim.keymap.set('i', '<C-p>', '<C-r>"', { desc = 'Paste' })

vim.keymap.del('i', '<C-w>')
