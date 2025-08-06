----------------------------------------------------------------------
--- Standard Library
----------------------------------------------------------------------

--- Looks for the last match of `pattern` in the string.
---
--- Behaves like `string.find` but starts searching at the end of the string.
---
--- See [find documentation](http://www.lua.org/manual/5.1/manual.html#pdf-string.find).
---
---@param s       string|number
---@param pattern string|number
---@param init?   integer
---@param plain?  boolean
---@return integer|nil start
---@return integer|nil end
---@return any|nil ... captured
---@nodiscard
function string.rfind(s, pattern, init, plain)
    if type(init) == 'number' then init = -1 * init end
    local i, j = s:reverse():find(pattern:reverse(), init, plain)
    if type(i) == 'number' and type(j) == 'number' then
        return #s + 1 - j, #s + 1 - i
    end
    return nil
end

--- Find an entry in a table using a predicate function
---
---@generic T
---@param func fun(value: T): boolean (function) Function
---@param t table<any, T> (table) Table
---@return T|nil (value) The first element that passes the predicate or nil
function vim.tbl_find(func, t)
    vim.validate('func', func, 'callable')
    vim.validate('t', t, 'table')

    for _, entry in ipairs(t) do
        if func(entry) then
            return entry
        end
    end
    return nil
end

----------------------------------------------------------------------
--- Common
----------------------------------------------------------------------

---Create a grouped keymapper.
---
---Returns a keymapper function with an API very similar to `vim.keymap.set`.
---Calling the returned keymapper function create a new keymap.
---
---Keymapper function parameters:
--- - `mode`: Mode short-name, see `|nvim_set_keymap()|`.
--- - `lhs`: Left-hand `{lhs}` of the mapping.
--- - `rhs`: Right-hand `{rhs}` of the mapping, can be a Lua function.
--- - `description`: Appended to `label` with `': '`, if given, for the description.
--- - `extra_opts`: Table of `|:map-arguments|`.
---
---The description of a keymap is the concatenation of the group `label` and
---the given `description`, if any. If a `description` is given then the
---description is `label .. ': ' .. description`. If no `description` is given
---then the description is just `label`.
---
---The options passed to `vim.keymap.set` are `group_opts`, overlayed with
---`extra_opts`, overlayed with the description.
---
---@param group_label string The group mapping label.
---@param group_opts table? The group options (see `|:map-arguments|`).
---@return fun(mode: string|table, lhs: string, rhs: string|function, description: string?, extra_opts: table?)
function Map(group_label, group_opts)
    return function(mode, lhs, rhs, description, extra_opts)
        local desc = group_label
        if description then desc = desc .. ': ' .. description end
        local opts = vim.tbl_extend(
            'force',
            group_opts or {},
            extra_opts or {},
            { desc = desc }
        )
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

function pinspect(...)
    for _, value in ipairs({ ... }) do
        print(vim.inspect(value))
    end
end

-- function deepcopy(orig)
--     local copy
--
--     if type(orig) == 'table' then
--         copy = {}
--         for o_k, o_v in pairs(orig) do
--             copy[deepcopy(o_k)] = deepcopy(o_v)
--         end
--         setmetatable(copy, deepcopy(getmetatable(orig)))
--     else
--         copy = orig
--     end
--
--     return copy
-- end

--- Dump value of a variable in a formatted string
--
--- @param o       any         Dumpable object
--- @param indent  string|nil  Tabulation string, '  ' by default
--- @param depth   number|nil  Initial tabulation level, 0 by default
--- @param lines   table|nil
--- @param prefix  string|nil
--- @return        string
function dump(o, indent, depth, lines, prefix)
    lines = lines or {}
    prefix = prefix or ''

    local t = type(o)
    if t == 'string' then
        table.insert(lines, prefix .. '"' .. o .. '"')
        return lines
    elseif t ~= 'table' then
        table.insert(lines, prefix .. tostring(o))
        return lines
    end

    if not next(o) then
        table.insert(lines, prefix .. '{}')
        return lines
    end

    depth = depth or 0
    indent = indent or '  '
    local indent_ = function() return indent:rep(depth) end

    table.insert(lines, prefix .. '{')

    depth = depth + 1
    for k, v in pairs(o) do
        if type(k) == 'string' then k = '"' .. k .. '"' end
        local p = indent_() .. '[' .. k .. '] = '
        if k == '"fs_stat"' then
        elseif k == '"parent"' then
        elseif depth < 5 then
            dump(v, indent, depth, lines, p)
        else
            table.insert(lines, p .. '...')
        end
    end
    depth = depth - 1

    table.insert(lines, indent_() .. '}')
    return lines
end

function display(thing)
    vim.cmd('split')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, dump(thing))
end

----------------------------------------------------------------------
--- Table Methods
----------------------------------------------------------------------

function _table_merge(dest, a, b)
    for k, b_v in pairs(b) do
        if type(b_v) == 'table' and type(a[k] or false) == 'table' then
            dest[k] = _table_merge(dest[k], a[k], b_v)
        else
            dest[k] = b_v
        end
    end
    return dest
end

-- Merge two tables, values in `b` overwrite those in `a`.
--
-- Source: https://stackoverflow.com/questions/1283388
--
-- Tables can't use colon functions because they don't have metatables.
-- See: https://stackoverflow.com/a/33052346/5673922
function table.merge(a, b)
    if type(b) ~= 'table' then
        error('Expected table')
    end

    return _table_merge(vim.deepcopy(a), a, b)
end

-- -- A more simple implementation that mutates `a`
-- function table.merge(a, b)
--     if type(b) ~= 'table' then
--         error('Expected table')
--     end
--
--     for k, v in pairs(b) do
--         if type(v) == 'table' and type(a[k] or false) == 'table' then
--             a[k] = table.merge_mut(a[k], v)
--         else
--             a[k] = v
--         end
--     end
--
--     return a
-- end

----------------------------------------------------------------------
--- Plugin Utilities
----------------------------------------------------------------------

function module_exists(module)
    status, _ = pcall(require, module)
    return status
end

function check_module(module)
    return function()
        return module_exists(module)
    end
end
