-- Intelligently restore last cursor position of file

return {
    pack = {
        src = { github = 'ethanholz/nvim-lastplace' },
    },

    spec = {
        'nvim-lastplace',

        -- Must be loaded before the `BufWinEnter` event because that's when the
        -- cursor restore happens.
        event = 'BufReadPost',

        after = function()
            -- For some reason the setup code that ensures `lastplace.options` is a
            -- table doesn't work which causes an exception. Ensure options is not
            -- `nil`.
            require('nvim-lastplace').setup({})
        end,
    },
}
