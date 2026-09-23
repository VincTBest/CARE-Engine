

local doPrint = false
function setDPrint(to) doPrint = to end
function getDPrint() return doPrint end

function dprint(...)
    if doPrint then print(...) end
end

function table.print(t, depth, keys)
    depth = depth or 8
    keys  = keys or {}
    for k, v in pairs(t) do
        table.insert(keys, k)
        local type = type(v)
        if type == "table" and depth > 0 then
            table.print(v, depth-1, keys)
            table.remove(keys)
        else
            print(createKeyPres(keys)..tostr(v))
            table.remove(keys)
        end
    end
end

function createKeyPres(keys)
    local s = ""

    for i=1,#keys do s = s..keys[i]..": " end
    return s
end


-- Source - https://stackoverflow.com/q/2282444
-- Posted by Wookai, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-09-06, License - CC BY-SA 2.5

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.containsK(table, keyname)
    for key, _ in pairs(table) do
        if key == keyname then
            return true
        end
    end
    return false
end

function table.merge(tables)
    local merged = tables[1]
    for i=2,#tables do
        for k, v in pairs(tables[i]) do
            merged[k] = v
        end
    end
    return merged
end

-- function rCol(pattern, precision)
--     pattern = tostr(pattern)
--     precision = precision or 1000
--     local color = {1, 1, 1, 1}
--     for i=1,#color do
--         if pattern.sub(i, i) == "1" then
--             color[i] = math.random(0, precision) / precision
--         end
--     end
--     return color
-- end

function rCol(pattern)
    local color = {1,1,1,1}

    if pattern == "1110" then
        color = {
            math.random(),
            math.random(),
            math.random(),
            1
        }
    end

    return color
end

-- Source - https://stackoverflow.com/a/7615129
-- Posted by user973713, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-09-20, License - CC BY-SA 4.0

-- Replaced by Penlight: split, trim.
-- function string.split(inputStr, sep)
--     if sep == nil then
--         sep = "%s"
--     end
--     local t = {}

--     for str in string.gmatch(inputStr, "([^"..sep.."]+)") do
--         table.insert(t, str)
--     end
--     return t
-- end
--
-- function string.trim(s)
--     return s:gsub("^%s*(.-)%s*$", "%1")
-- end

function joinPath(...)
    local args = {...}
    local parts = {}

    for i, part in ipairs(args) do
        local str = tostr(part)

        if i > 1 then
            str = str:gsub("^([/\\]+)", "")
        end
        if i < #args then
            str = str:gsub("([/\\]+)$", "")
        end

        if str ~= "" then
            table.insert(parts, str)
        end
    end

    return table.concat(parts, "/")
end

function normalizePath(path)
    local old_path
    repeat
        old_path = path
        path = path:gsub("[^/]+%/%.%.%/", "")
    until old_path == path
    return path
end
