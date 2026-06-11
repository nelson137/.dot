-- Ensure the undo directory exists
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    group = vim.api.nvim_create_augroup('EnsureUndoDir', {}),
    pattern = { '*' },
    callback = function()
        vim.fn.mkdir(vim.g.undodir, 'p')
    end,
})
