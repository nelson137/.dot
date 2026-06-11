-- Startup time graph

return {
    pack = {
        src = { github = 'dstein64/vim-startuptime' },
    },

    spec = {
        'vim-startuptime',

        cmd = 'StartupTime',

        before = function()
            vim.g.startuptime_tries = 5
        end,
    },
}
