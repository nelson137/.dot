-- Configure LuaLS for Neovim development

return {
    'folke/lazydev.nvim',

    ft = 'lua',

    ---@module 'lazydev'
    ---@type lazydev.Config
    opts = {
        enabled = function(root_dir)
            return not vim.uv.fs_stat(root_dir .. '/.luarc.json') and
                root_dir == vim.env.HOME .. '/.dot'
        end,
        library = {
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
    },
}
