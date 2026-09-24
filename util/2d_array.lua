
function create2DArray(w, h, defaultEl)
    -- Basically userdata from Picotron.
    defaultEl = defaultEl or 0

    local array = {
        data = {},
        w = w,
        h = h,
    }

    for _ = 1, h do
        local row = {}
        for _ = 1, w do
            table.insert(row, defaultEl)
        end
        table.insert(array.data, row)
    end
    --print("-------------:>")
    --print(type(array.data))
    --print(type(array.data[1]))
    --table.print(array.data)
    --print("-------------<:")

    function array.get(x, y)
        local el = array.data[y][x]
        --print("get:>")
        --table.print(array.data)
        --print(json.encode(array.data))
        --print(type(array.data))
        --print("Getting: "..tostr(x).."-"..tostr(y).."... ("..tostr(el)..")")
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
        array.forEach(function(ov, _, _) return exp(ov, v) end)
    end

    return array
end

ARITH = {
    ADD = function(o, v) return o+v end,
    SUB = function(o, v) return o-v end,
    MUL = function(o, v) return o*v end,
    DIV = function(o, v) return o/v end,
}
