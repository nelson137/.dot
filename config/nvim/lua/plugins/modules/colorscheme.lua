-- Color scheme

return {
    'sainnhe/sonokai',

    lazy = false,

    priority = 1000,

    config = function()
        vim.g.sonokai_style = 'andromeda'
        vim.g.sonokai_better_performance = 1
        vim.g.sonokai_enable_italic = 1
        vim.g.sonokai_dim_inactive_windows = 1
        vim.cmd.colorscheme('sonokai')

        local config = vim.fn['sonokai#get_configuration']()
        local palette = vim.fn['sonokai#get_palette'](config.style, config.colors_override)

        -- Sonokai changes the `DiffText` hightlight bg to a blue that makes
        -- text illegible:
        --
        -- ```vimscript
        -- call sonokai#highlight('DiffText', s:palette.bg0, s:palette.blue)
        -- ```
        --
        -- Make the blue darker so that we can read the text.
        --
        -- Original palette blue: `{ '#6dcae8', '110' }`
        --
        local diff_blue = { '#3d4852', '110' }
        vim.fn['sonokai#highlight']('DiffText', palette.bg0, diff_blue)
    end,
}
