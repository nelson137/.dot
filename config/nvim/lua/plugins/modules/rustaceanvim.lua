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

vim.g.rustaceanvim = {
    server = {
        on_attach = on_attach,
        default_settings = {
            ['rust-analyzer'] = rust_analyzer_settings,
        },
    },
}

return {
    'mrcjkb/rustaceanvim',

    version = '^4',

    ft = { 'rust' },
}
