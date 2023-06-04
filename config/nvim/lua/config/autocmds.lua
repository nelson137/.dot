-- Ensure the undo directory exists
vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
    group = vim.api.nvim_create_augroup('EnsureUndoDir', {}),
    pattern = { '*' },
    callback = function()
        vim.fn.mkdir(vim.g.undodir, 'p')
    end,
})

-- ColorColumn in git buffers
vim.api.nvim_create_autocmd({ 'FileType' }, {
    group = vim.api.nvim_create_augroup('ColorColumn', {}),
    pattern = { 'gitcommit', 'git-rebase-todo' },
    callback = function()
        vim.opt.colorcolumn = { 73 }
    end,
})
