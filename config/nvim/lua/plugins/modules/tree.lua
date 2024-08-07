-- Tree file explorer

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Defaults
local filesystem_watchers = {
    enable = true,
    debounce_delay = 50,
    ignore_dirs = {},
}

local tree_opts = { find_file = true, update_root = false }

-- If opening a directory, open nvim-tree
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = vim.api.nvim_create_augroup('UseNvimTreeForDirs', {}),
    pattern = { '' },
    callback = function()
        if vim.fn.expand('%:p'):sub(-1) == '/' then
            -- API must be required
            local api = require('nvim-tree.api')
            api.tree.toggle(tree_opts)
        end
    end,
})

local function tree_api() return require('nvim-tree.api') end
local function tree_lib() return require('nvim-tree.lib') end
local function tree_utils() return require('nvim-tree.utils') end

local tree_toggle = function()
    tree_api().tree.toggle(tree_opts)
end

-- FILE: /full/path/to/file.txt
--
-- r    Api.fs.rename(_node)    ":t"    file.txt
-- C-r  Api.fs.rename_sub       ":p:h"  /full/path/to/
-- e    Api.fs.rename_basename  ":t:r"  file
--
-- Modifiers:
--   :p  expand to full path
--   :h  head (last path component removed)
--   :t  tail (last path component only)
--   :r  root (one extension removed)
--   :e  extension only

local on_attach = function(bufnr)
    local api = tree_api()
    local lib = tree_lib()
    local utils = tree_utils()
    local Event = api.events.Event

    -- local function map(mode, lhs, rhs, desc)
    --     local opts = {
    --         buffer = bufnr,
    --         desc = 'nvim-tree: ' .. desc,
    --         noremap = true,
    --         silent = true,
    --         nowait = true,
    --     }
    --     vim.keymap.set('n', lhs, rhs, opts)
    -- end

    api.config.mappings.default_on_attach(bufnr)

    -- api.events.subscribe(Event.NodeRenamed, function(data)
    --     local ts_clients = vim.lsp.get_active_clients({ name = 'tsserver' })
    --     local responses = {}
    --     for _, ts_client in ipairs(ts_clients) do
    --         local r = ts_client.request_sync(
    --             'workspace/executeCommand',
    --             {
    --                 command = '_typescript.applyRenameFile',
    --                 arguments = {
    --                     {
    --                         sourceUri = vim.uri_from_fname(data.old_name),
    --                         targetUri = vim.uri_from_fname(data.new_name),
    --                     }
    --                 },
    --             },
    --             3000
    --         )
    --         table.insert(responses, r)
    --     end
    --     display(responses)
    --
    --     -- if not filesystem_watchers.enable then
    --     --     require('nvim-tree.actions.reloaders.reloaders').reload_explorer()
    --     -- end
    --
    --     -- local find_file = require('nvim-tree.actions.finders.find-file').fn
    --     -- find_file(utils.path_remove_trailing(dst_abs))
    -- end)
end

return {
    'nvim-tree/nvim-tree.lua',

    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },

    event = 'BufReadPre',

    keys = {
        { '<Leader>e', tree_toggle },
    },

    opts = {
        on_attach = on_attach,
        filesystem_watchers = filesystem_watchers,
        hijack_cursor = true,
        -- TODO: Implement hijack for all directories. This currently only works
        -- TODO: for `:e DIR`. Make this work when any new buffer is a dir.
        -- TODO: Note, must change lazy `event` for this to work.
        hijack_directories = {
            enable = true,
            auto_open = true,
        },
        hijack_unnamed_buffer_when_opening = true,
        notify = {
            absolute_path = false,
        },
        reload_on_bufenter = true,
        renderer = {
            highlight_git = true,
            icons = {
                git_placement = 'after',
            },
        },
        update_focused_file = {
            enable = true,
            -- update_root = true,
        },
        view = {
            float = {
                enable = true,
            },
            width = {
                min = 40,
                max = 100,
            },
        },
    },
}
