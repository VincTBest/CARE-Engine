
function create2DArray(w, h, defaultEl)
    -- Basically userdata from Picotron.
    if defaultEl == nil then defaultEl = 0 end

    local array = {
        data = {},
        w = w,
        h = h,
    }

    for _i = 1, h do
        local row = {}
        for _j = 1, w do
            table.insert(row, defaultEl)
        end
        table.insert(array.data, row)
    end

    function array.get(x, y)
        local el = array.data[y][x]
        return el
    end

    function array.set(x, y, v)
        array.data[y][x] = v
    end

    function array.forEach(func)
        for y = 1, array.h do
            for x = 1, array.w do
                local el = array.data[y][x]
                array.data[y][x] = func(el, x, y)
            end
        end
    end

    function array.arith(exp, v)
        array.forEach(function(ov, _x, _y) return exp(ov, v) end)
    end

    return array
end

local ARITH = {
    ADD = function(o, v) return o+v end,
    SUB = function(o, v) return o-v end,
    MUL = function(o, v) return o*v end,
    DIV = function(o, v) return o/v end,
}
