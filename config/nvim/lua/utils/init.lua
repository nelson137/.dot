----------------------------------------------------------------------
--- Common
----------------------------------------------------------------------

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

----------------------------------------------------------------------
--- String Methods
----------------------------------------------------------------------

function string:endswith(suffix)
    return self:sub(-#suffix) == suffix
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
