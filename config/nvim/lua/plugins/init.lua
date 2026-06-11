-- vim:foldmethod=marker

require('plugins.colorscheme')

-- Build hooks {{{
--
-- `vim.pack` does not run build steps, so do it ourselves when a plugin is first
-- installed or updated. This MUST be registered *before* `vim.pack.add()`, since
-- those calls fire `PackChanged` synchronously while installing.

vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('PackBuild', {}),
    callback = function(ev)
        local data = ev.data
        if data.kind == 'delete' then return end

        local builds = {
            ['LuaSnip'] = 'make install_jsregexp',
            ['telescope-fzf-native.nvim'] =
            'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        }

        local cmd = builds[data.spec.name]
        if cmd then
            vim.notify(('Building %s...'):format(data.spec.name))
            vim.system({ 'sh', '-c', cmd }, { cwd = data.path }):wait()
        end
    end,
})

-- }}}

-- Eager plugins {{{
--
-- Installed *and* sourced immediately.

vim.pack.add({
    { src = 'https://github.com/lumen-oss/lz.n' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' }, -- shared optional icon provider: lualine/bufferline/neo-tree/trouble/which-key/snacks/telescope
}, { confirm = false })

-- }}}

-- Collect modules {{{
--
-- Build the `modules` list by `require`-ing every `.lua` file in `modules/`.
-- Each returns a table describing one plugin: `pack` (a loose package spec whose
-- `src` is either a URL string or a `{ github = 'owner/repo' }` shorthand),
-- `spec` (the lz.n spec consumed in the next block), and an optional `disabled`
-- flag. `create_vimpack_spec` normalizes a module's `pack` into a real
-- `vim.pack.Spec`, expanding the github shorthand and carrying over
-- `name`/`version`/`data`.

local modules_dir = vim.fn.stdpath('config') .. '/lua/plugins/modules'
local modules = {}

for filename, type in vim.fs.dir(modules_dir) do
    local name = filename:match('^(.+)%.lua$')
    if type == 'file' and name then
        modules[#modules + 1] = require('plugins.modules.' .. name)
    end
end

---Create a `vim.pack.Spec` from module `data.pack`.
---@param data any
---@return vim.pack.Spec|nil
local function create_vimpack_spec(data)
    if type(data) ~= 'table' then return nil end
    local spec = {}

    if type(data.src) == 'string' then
        spec.src = data.src
    elseif type(data.src) == 'table' then
        if type(data.src.github) == 'string' then
            spec.src = 'https://github.com/' .. data.src.github
        else
            return nil
        end
    end

    spec.name = data.name
    spec.version = data.version
    spec.data = data.data

    return spec
end

-- }}}

-- Lazy load plugins {{{
--
-- Installed but *not* sourced (`load = function() end`). lz.n `:packadd`s each on
-- its trigger (event/cmd/ft/keys) per the spec in its `modules/` file.

local lazy_modules = vim.tbl_filter(
    function(x) return x end,
    vim.tbl_map(function(m)
        print()
        if m.disabled then return nil end

        local pack = create_vimpack_spec(m.pack)
        if pack == nil then return nil end
        m.pack = pack

        return m
    end, modules)
)

-- Install and register but do not load
vim.pack.add(
    vim.tbl_map(function(m) return m.pack end, lazy_modules),
    { load = function() end }
)

require('lz.n').load(vim.tbl_map(function(m) return m.spec end, lazy_modules))

-- }}}
