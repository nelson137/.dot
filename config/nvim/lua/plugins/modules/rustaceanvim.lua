-- Configure Rust language server

local function code_action() vim.cmd.RustLsp('codeAction') end

local function on_attach(_, bufnr)
    local map = function(mode, lhs, rhs, desc)
        local opts = { buffer = bufnr, desc = 'RustLsp: ' .. desc }
        vim.keymap.set(mode, lhs, rhs, opts)
    end
    map('n', '<Leader>.', code_action, 'codeAction')
end

local rust_analyzer_settings = {
    completion = {
        callable = {
            snippets = 'add_parentheses',
        },
    },
    imports = {
        granularity = {
            enforce = true,
        },
    },
}

-- rustaceanvim is a filetype plugin: it activates itself on rust buffers, so it
-- must be a *start* plugin (sourced eagerly by `vim.pack.add`) rather than
-- lazy-loaded on `ft`. It is configured via `vim.g.rustaceanvim`, which it reads
-- the first time a rust buffer starts the LSP, so setting it in `before` (at
-- startup) is in time.
return {
    pack = {
        src = { github = 'mrcjkb/rustaceanvim' },
        version = vim.version.range('^6'),
    },

    spec = {
        'rustaceanvim',

        lazy = false,

        before = function()
            ---@module 'rustaceanvim'
            ---@type rustaceanvim.Config
            vim.g.rustaceanvim = {
                ---@type rustaceanvim.lsp.ClientConfig
                server = {
                    on_attach = on_attach,
                    default_settings = {
                        ['rust-analyzer'] = rust_analyzer_settings,
                    },
                },
            }
        end,
    },
}
