-- Configure Rust language server through rust-tools.
-- See [config options](https://github.com/simrat39/rust-tools.nvim#configuration)

local function on_attach(client, buffer)
    local rust_tools = require('rust-tools')

    local key_opts = { buffer = buffer }
    vim.keymap.set('n', '<Leader>k', rust_tools.hover_actions.hover_actions, key_opts)
end

-- See [rust-analyzer config options](https://rust-analyzer.github.io/manual.html#configuration)
local rust_analyzer_settings = {
    completion = {
        callable = {
            -- Don't fill arguments when completing callables
            snippets = 'add_parentheses',
        },
    },
    check = {
        command = 'clippy',
    },
    imports = {
        granularity = {
            enforce = true,
        },
    },
}

return {
    'simrat39/rust-tools.nvim',

    opts = {
        tools = {
            inlay_hints = {
                auto = true,
                -- show_parameter_hints = false,
                parameter_hints_prefix = '',
                other_hints_prefix = '',
            },
            hover_actions = {
                auto_focus = true,
            },
            runnables = {
                use_telescope = true,
            },
        },

        -- Config for nvim-lspconfig, these override the defaults from rust-tools
        -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
        server = {
            on_attach = on_attach, -- called when the server attaches to the buffer
            settings = {
                ['rust-analyzer'] = rust_analyzer_settings,
            },
        },
    },
}
