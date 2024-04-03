-- Configure LuaLS for Neovim development

return {
    'folke/neodev.nvim',
    lazy = false,
    priority = 100,
    opts = {
        setup_jsonls = true,
        pathStrict = true,
        override = function(root_dir, library)
            if root_dir:find(vim.env.HOME .. '.dot/config/nvim', 1, true) == 1 then
                library.enabled = true
                library.plugins = true
            end
        end,
    },
}
