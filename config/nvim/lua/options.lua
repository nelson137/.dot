-- Use surrounding lines to infer indent of a new line
vim.opt.autoindent = true

-- Use IDE-like backspace
-- indent: backspace over autoindent
-- eol: backspace over line endings
-- start: backspace over the start of inserts
vim.opt.backspace = { 'indent', 'eol', 'start' }

-- Enable C program indenting -- works better than 'smartindent' in most cases
vim.opt.cindent = true
-- vim.opt.cinkeys = vim.opt.cinkeys - '0#'

-- Use system clipboard by default
vim.opt.clipboard = 'unnamedplus'

-- Set completeopt to have a better completion experience
-- menuone: Popup even when there's only one match
-- noinsert: Don't insert completion until a selection is made
-- noselect: Don't auto-select
vim.opt.completeopt = 'menuone,noinsert,noselect'

-- Copy structure of surrounding lines for new indent, overriding 'expandtab'
vim.opt.copyindent = true

-- Team spaces
vim.opt.expandtab = true

-- Set which motion commands can cause a fold to open
vim.opt.foldopen = 'hor,insert,mark,percent,quickfix,search,tag,undo'

-- Don't highlight all search matches
vim.opt.hlsearch = false

-- Search case-insensitively
vim.opt.ignorecase = true

-- Perform search while typing
vim.opt.incsearch = true

-- Always show the status line
vim.opt.laststatus = 2

-- Show unwanted whitespace characters
vim.opt.list = true
vim.opt.listchars = 'tab:»»,trail:·,nbsp:~'

-- Show the current line number and the relative number of surrounding lines
vim.opt.number = true
vim.opt.relativenumber = true

-- Number of buffer lines around cursor when scrolling at the edge of the window
vim.opt.scrolloff = 4

-- Disable verbose prompts & messages
vim.opt.shortmess = 'acoOtT'

-- One auto-indent is 4 spaces
vim.opt.shiftwidth = 4

-- Always show the tab line
vim.opt.showtabline = 2

-- Always show the sign column
vim.opt.signcolumn = 'yes'

-- Override 'ignorecase' when search has uppercase letters
vim.opt.smartcase = true

-- -- Try to be context-aware about indenting new lines
-- -- Overridden by 'cindent'
-- vim.opt.smartindent = true

-- Insertions and deletions use 4 spaces for indents
vim.opt.softtabstop = 4

-- Open new horizontal splits below & vertical splits to the right
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Indents are 4 spaces
vim.opt.tabstop = 4

vim.opt.termguicolors = true

vim.opt.timeoutlen = 500

vim.opt.undodir = vim.g.undodir
vim.opt.undofile = true
vim.opt.undolevels = 1000

-- Threshold for no cursor movement to trigger `CursorHold`, in milliseconds
vim.opt.updatetime = 400

vim.opt.visualbell = true

vim.opt.wildmenu = true

-- Floating window border
vim.opt.winborder = 'rounded'
