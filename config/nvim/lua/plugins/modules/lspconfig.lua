-- Common language server configs

-- Copied from |vim.diagnostic|.
local function _diagnostic_move_pos(opts, pos)
    opts = opts or {}

    local float = vim.F.if_nil(opts.float, true)
    local win_id = opts.win_id or vim.api.nvim_get_current_win()

    if not pos then
        return
    end

    vim.api.nvim_win_call(win_id, function()
        -- Save position in the window's jumplist
        vim.cmd([[normal! m']])
        vim.api.nvim_win_set_cursor(win_id, { pos[1] + 1, pos[2] })
        -- Open folds under the cursor
        vim.cmd([[normal! zv]])
    end)

    if float then
        local float_opts = type(float) == 'table' and float or {}
        vim.schedule(function()
            vim.diagnostic.open_float(vim.tbl_extend('keep', float_opts, {
                bufnr = vim.api.nvim_win_get_buf(win_id),
                scope = 'cursor',
                focus = false,
            }))
        end)
    end
end

local function lsp_goto_diagnostic(get_pos, opts)
    opts = opts or {}
    -- Severities go from ERROR (1) to HINT (4)
    for sev, _ in ipairs(vim.diagnostic.severity) do
        local get_pos_opts = vim.tbl_extend('force', opts, { severity = sev })
        local pos = get_pos(get_pos_opts)
        if pos then
            _diagnostic_move_pos(opts, pos)
            return
        end
    end

    vim.api.nvim_echo({ { 'No diagnostics to move to', 'WarningMsg' } }, true, {})
end

local function lsp_goto_next_diagnostic() lsp_goto_diagnostic(vim.diagnostic.get_next_pos) end
local function lsp_goto_prev_diagnostic() lsp_goto_diagnostic(vim.diagnostic.get_prev_pos) end

local function lsp_references()
    require('telescope.builtin').lsp_references({
        include_declaration = true,
        include_current_line = true,
    })
end

local on_attach = function(ev)
    local telescope = require('telescope.builtin')

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local key_opts = { buffer = ev.buf }

    vim.diagnostic.config({
        severity_sort = true,
    })

    -- Use conform for range formatting
    vim.bo[ev.buf].formatexpr = "v:lua.require'conform'.formatexpr()"

    -- Disable semantic token highlighting, let Treesitter do that
    client.server_capabilities.semanticTokensProvider = nil

    -- Code actions
    vim.keymap.set({ 'n', 'v' }, '<Leader>.', vim.lsp.buf.code_action, key_opts)
    vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, key_opts)

    -- Code info
    vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help, key_opts)

    -- Jump to code
    vim.keymap.set('n', '<Leader>gd', telescope.lsp_definitions, key_opts)
    vim.keymap.set('n', '<Leader>gD', telescope.lsp_type_definitions, key_opts)
    vim.keymap.set('n', '<Leader>gi', telescope.lsp_implementations, key_opts)
    vim.keymap.set('n', '<Leader>gr', telescope.lsp_references, key_opts)
    vim.keymap.set('n', '<Leader>gS', telescope.lsp_document_symbols, key_opts)

    -- Jump to diagnostics
    vim.keymap.set('n', 'g]', lsp_goto_next_diagnostic, key_opts)
    vim.keymap.set('n', 'g[', lsp_goto_prev_diagnostic, key_opts)
    vim.keymap.set('n', 'g}', vim.diagnostic.goto_next, key_opts)
    vim.keymap.set('n', 'g{', vim.diagnostic.goto_prev, key_opts)

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
