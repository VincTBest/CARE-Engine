-- Shortenings

function clear(r, g, b, a)
    love.graphics.clear()
    if r ~= nil then
        local ww, wh = love.window.getMode()
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", 0, 0, ww, wh)
    end
end

function rect( mode, x, y, width, height, rx, ry, segments )
    love.graphics.rectangle( mode, x, y, width, height, rx, ry, segments )
end

function tostr(v) return tostring(v) end
function tonum(e) return tonumber(e) end
