

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
    for i = 2, #tables do
        for k, v in pairs(tables[i]) do
            merged[k] = v
        end
    end
    return merged
end

function table.clone(tbl)
    return {table.unpack(tbl)}
end

function table.copy(tbl)
    local new = {}

    for _, v in ipairs(tbl) do
        table.insert(new, v)
    end

    return new
end

function table.deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[table.deepcopy(orig_key, copies)] = table.deepcopy(orig_value, copies)
            end
            setmetatable(copy, table.deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.copyK(tbl)
    local new = {}

    for k, v in pairs(tbl) do
        new[k] = v
    end

    return new
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

function string.startswith(str1, str2)
    return str1:sub(1, #str2) == str2
end

function table.getBiggest(tbl)
	local biggest, biggest_key = nil, nil

	for k, v in pairs(tbl) do
		if type(v) == "number" and (biggest == nil or v > biggest) then
			biggest, biggest_key = v, k
		end
	end

	return biggest, biggest_key
end

function Vec2(p1, p2, p3)
    if p3 then
        if type(p1) == "table" then
            if type(p2) == "number" and type(p3) == "number" then
                p1.x, p1.y = p2, p3
                return p1
            else
                error("A Vec2's x and y must be numbers")
            end
        else
            error("A Vec2's x and y must be numbers")
        end
    else
        if type(p1) == "number" and type(p2) == "number" then
            return {x=p1, y=p2}
        else
            error("A Vec2's x and y must be numbers")
        end
    end
end

function Vec3(x, y, z)
    return {x=x, y=y, z=z}
end

function Vec4(x, y, z, w)
    return {x=x, y=y, z=z, w=w}
end

function Vec5(x, y, z, w, v)
    return { x = x, y = y, z = z, w = w, v = v }
end

function deg_to_rad(deg)
    return deg * (math.pi / 180)
end

function rad_to_deg(rad)
    return rad * (180 / math.pi)
end

local serrors = {}
function serror(msg)
    if not table.contains(serrors, msg) then
        print("[serror]: " .. tostr(msg))
        table.insert(serrors, msg)
    end
end

function UnixTS()
    return os.time(os.date("!*t"))
end

function UnixTSToTime(unix, format)
    format = format or "%c"
    return os.date(format, unix)
end

-- Shortenings

function tostr(v) return tostring(v) end
function tonum(e)
    if type(e) == "bool" then
        return e == true
    end
    return tonumber(e)
end
