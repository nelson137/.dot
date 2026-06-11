-- Switch text under the cursor with `gs`

return {
    pack = {
        src = { github = 'AndrewRadev/switch.vim' },
    },

    spec = {
        'switch.vim',

        event = 'DeferredUIEnter',
    },
}
