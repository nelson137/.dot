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
---@return T? (value) The first element that passes the predicate or nil
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

---@class Entry
---@field key string
---@field value any

---Transform a list of key-value pairs into an object.
---@param table Entry[] an array of entries
---@returns table<string, any> an object where the
function vim.tbl_from_entries(table)
    local output = {}
    for _, o in ipairs(table) do
        output[o.key] = o.value
    end
    return output
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

function Pinspect(...)
    for _, value in ipairs({ ... }) do
        print(vim.inspect(value))
    end
end

----------------------------------------------------------------------
--- Table Methods
----------------------------------------------------------------------

function table._merge_impl(dest, a, b)
    for k, b_v in pairs(b) do
        if type(b_v) == 'table' and type(a[k] or false) == 'table' then
            dest[k] = table._merge_impl(dest[k], a[k], b_v)
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

    return table._merge_impl(vim.deepcopy(a), a, b)
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
