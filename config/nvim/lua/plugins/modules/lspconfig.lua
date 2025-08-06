-- Common language server configs

---@param direction 1|-1 Whether to jump to the next (`1`) or prev (`-1`)
---    diagnostic.
---@return fun() A function that jumps to the next diagnostic in the given
---    direction.
local function diagnostic_jump(direction)
    return function() vim.diagnostic.jump({ count = direction, float = true }) end
end

---@param direction 1|-1 Whether to jump to the next (`1`) or prev (`-1`)
---    diagnostic.
local function lsp_goto_diagnostic(direction, opts)
    opts = opts or {}
    -- Severities go from ERROR (1) to HINT (4)
    for sev, _ in ipairs(vim.diagnostic.severity) do
        local jump_opts = vim.tbl_extend('force', opts, {
            count = direction,
            float = true,
            severity = sev,
        })
        local diagnostic = vim.diagnostic.jump(jump_opts)
        if diagnostic then return end
    end

    vim.notify('No diagnostics to move to', vim.log.levels.WARN)
end

local function lsp_goto_next_diagnostic() lsp_goto_diagnostic(1) end
local function lsp_goto_prev_diagnostic() lsp_goto_diagnostic(-1) end

local function lsp_references()
    require('telescope.builtin').lsp_references({
        include_declaration = true,
        include_current_line = true,
    })
end

-- Default mappings for buffers that don't attach a client (e.g. toml).
-- Overridden by the same mappings below with extra options.
local default_map = Map('LSP')
default_map('n', 'g]', diagnostic_jump(1))
default_map('n', 'g[', diagnostic_jump(-1))

local on_attach = function(ev)
    local telescope = require('telescope.builtin')

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
        vim.notify('Invalid client_id: ' .. ev.data.client_id, vim.log.levels.WARN);
        return
    end
    local key_opts = { buffer = ev.buf }

    vim.diagnostic.config({
        severity_sort = true,
    })

    -- Use conform for range formatting
    vim.bo[ev.buf].formatexpr = "v:lua.require'conform'.formatexpr()"

    -- Disable semantic token highlighting, let Treesitter do that
    client.server_capabilities.semanticTokensProvider = nil

    local map = Map('LSP', key_opts)

    -- Code actions
    map({ 'n', 'v' }, '<Leader>.', vim.lsp.buf.code_action, 'code action')
    map('n', '<Leader>r', vim.lsp.buf.rename, 'rename symbol')

    -- Code info
    vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, key_opts)

    -- Jump to code
    map('n', '<Leader>gd', telescope.lsp_definitions, 'jump to definition(s)')
    map('n', '<Leader>gD', telescope.lsp_type_definitions, 'jump to type definition(s)')
    map('n', '<Leader>gi', telescope.lsp_implementations, 'jump to implementation(s)')
    map('n', '<Leader>gr', telescope.lsp_references, 'jump to references')
    map('n', '<Leader>gS', telescope.lsp_document_symbols, 'open document symbols')

    -- Jump to diagnostics
    map('n', 'g]', lsp_goto_next_diagnostic, 'jump to next most severe diagnostic')
    map('n', 'g[', lsp_goto_prev_diagnostic, 'jump to prev most severe diagnostic')
    map('n', 'g}', diagnostic_jump(1), 'jump to next hidiagnostic')
    map('n', 'g{', diagnostic_jump(-1), 'jump to prev hidiagnostic')

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

    event = { 'BufReadPre', 'BufNewFile' },

    dependencies = { 'nvim-telescope/telescope.nvim' },

    init = function()
        vim.lsp.config('angularls', {
            filetypes = { 'html', 'htmlangular' },
            root_markers = { 'angular.json', 'nx.json' },
        })

        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    telemetry = { enable = false },
                },
            },
        })

        vim.lsp.config('basedpyright', {
            settings = {
                basedpyright = {
                    analysis = {
                        typeCheckingMode = 'basic',
                    },
                },
            },
        })

        vim.g.format_on_save = true

        vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
            group = vim.api.nvim_create_augroup('FormatOnSave', {}),
            pattern = { '*' },
            callback = function()
                if vim.g.format_on_save then
                    require('conform').format()
                end
            end,
        })

        vim.api.nvim_create_user_command('SaveWithoutFormatting', function(opts)
            local original_value = vim.g.format_on_save
            vim.g.format_on_save = false
            vim.cmd.write({ bang = opts.bang })
            vim.g.format_on_save = original_value
        end, { bang = true })

        vim.api.nvim_create_user_command('ToggleFormatOnSave', function()
            vim.g.format_on_save = not vim.g.format_on_save
        end, {})

        vim.api.nvim_create_autocmd({ 'LspAttach' }, {
            group = vim.api.nvim_create_augroup('LspConfig', {}),
            pattern = { '*' },
            callback = on_attach,
        })
    end,
}
