-- Common LSP configs

-- TODO

local on_attach = function(ev)
    local telescope = require('telescope.builtin')

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local key_opts = { buffer = ev.buf }

    vim.diagnostic.config({
        signs = {
            severity = vim.diagnostic.severity.ERROR,
        },
    })

    -- Disable semantic token highlighting, let Treesitter do that
    client.server_capabilities.semanticTokensProvider = nil

    -- Code actions
    vim.keymap.set('n', '<Leader>.', vim.lsp.buf.code_action, key_opts)
    vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, key_opts)

    -- Code info
    vim.keymap.set('n', '<Leader>k', vim.lsp.buf.hover, key_opts)
    vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help, key_opts)

    -- Jump to code
    vim.keymap.set('n', '<Leader>gd', telescope.lsp_definitions, key_opts)
    vim.keymap.set('n', '<Leader>gD', telescope.lsp_type_definitions, key_opts)
    vim.keymap.set('n', '<Leader>gi', telescope.lsp_implementations, key_opts)
    vim.keymap.set('n', '<Leader>gr', telescope.lsp_references, key_opts)
    vim.keymap.set('n', '<Leader>g0', telescope.lsp_document_symbols, key_opts)

    -- Jump to diagnostics
    vim.keymap.set('n', 'g]', vim.diagnostic.goto_next, key_opts)
    vim.keymap.set('n', 'g[', vim.diagnostic.goto_prev, key_opts)

    -- -- Show diagnostic popup on cursor hover
    -- vim.api.nvim_create_autocmd('CursorHold', {
    --     group = vim.api.nvim_create_augroup('DiagnosticFloat', { clear = true }),
    --     callback = function()
    --         vim.diagnostic.open_float()
    --     end,
    -- })

    -- vim.keymap.set('n', '<C-h>', function()
    --     for _, win in ipairs(vim.api.nvim_list_wins()) do
    --         local config = vim.api.nvim_win_get_config(win)
    --         if config.relative ~= "" then
    --             vim.api.nvim_win_close(win, false)
    --             print('Closing window', win)
    --         end
    --     end
    -- end, key_opts)
end

return {
    'neovim/nvim-lspconfig',

    dependencies = { 'nvim-telescope/telescope.nvim' },

    event = { 'BufReadPre', 'BufNewFile' },

    init = function()
        vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
            group = vim.api.nvim_create_augroup('FormatOnSave', {}),
            pattern = { '*' },
            callback = function()
                vim.lsp.buf.format()
            end,
        })

        vim.api.nvim_create_autocmd({ 'LspAttach' }, {
            group = vim.api.nvim_create_augroup('LspConfig', {}),
            pattern = { '*' },
            callback = on_attach,
        })
    end,
}
