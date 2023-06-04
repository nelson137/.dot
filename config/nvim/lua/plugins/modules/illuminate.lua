-- Highlight instances of the symbol under the cursor like VS Code

return {
    'RRethy/vim-illuminate',

    event = 'VeryLazy',

    config = function(_, opts)
        require('illuminate').configure({
            delay = 300,
        })

        vim.cmd([[
            " cterm=235 :: gui=#262626
            " cterm=236 :: gui=#303030
            " cterm=237 :: gui=#3a3a3a
            hi! _IlluminatedShared cterm=NONE ctermbg=237 gui=NONE guibg=#3a3a3a
            hi! default link IlluminatedWordRead _IlluminatedShared
            hi! default link IlluminatedWordText _IlluminatedShared
            hi! default link IlluminatedWordWrite _IlluminatedShared
        ]])
    end,
}
