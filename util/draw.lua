
-- Camera

local CAMERA = {
    n = 1,
    c = {
        {x = 0, y = 0}
    }
}

function setCamera(x, y)
    CAMERA.c[CAMERA.n].x, CAMERA.c[CAMERA.n].y = x, y
end

function getCamera(n)
    n = n or CAMERA.n
    return CAMERA.n, CAMERA.c[n].x, CAMERA.c[n].y
end

function switchCamera(n)
    while n > #CAMERA.c do
        table.insert(CAMERA.c, {x = 0, y = 0})
    end
    CAMERA.n = n
end

function applyCamera(x, y)
    return x + CAMERA.c[CAMERA.n].x, y + CAMERA.c[CAMERA.n].y
end

-- Color

function setColor(r, g, b, a)
    if r and not g then
        love.graphics.setColor(r[1], r[2], r[3], r[4])
        return
    end
    love.graphics.setColor(r, g, b, a)
end

function setBlendMode(mode, alphaMode)
    love.graphics.setBlendMode(mode, alphaMode)
end

-- Font / Text

function setFont(font, size)
    size = tostr(size)
    if not table.containsK(font, size) then
        error("Font does not have size "..size.."!\n")
        return
    end
    love.graphics.setFont(font[size])
end

function text(text, x, y, ...)
    x, y = applyCamera(x, y)
    love.graphics.print(text, x, y, ...)
end

-- Primitives

function circle(x, y, r, segments)
    x, y = applyCamera(x, y)
    love.graphics.circle("line", x, y, r, segments)
end
function circleFill(x, y, r, segments)
    x, y = applyCamera(x, y)
    love.graphics.circle("fill", x, y, r, segments)
end

-- Other

function draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
    x, y = applyCamera(x, y)
    love.graphics.draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
end

-- Loading

function loadImage(path)
    print("Loading image: "..path)
    return love.graphics.newImage("project/"..getData("projectMeta")["dirs"]["images"].."/"..path)
end

FONTSIZES_REGULAR = {4, 8, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 34, 38, 42, 48, 52, 58, 64}
FONTSIZES_REDUCED = {8, 12, 18, 24, 30, 36, 44, 50, 64}
FONTSIZES_INCREASED = {2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64}

function loadFonts(path, sizes)
    path = "project/"..getData("projectMeta")["dirs"]["fonts"].."/"..path
    sizes = sizes or FONTSIZES_REGULAR

    print("Loading font: "..path)

    if type(sizes) == "number" then
        return {
            [tostr(sizes)] = love.graphics.newFont(path)
        }
    end

    local font = {}
    for i=1,#sizes do
        local size = sizes[i]
        font[tostr(size)] = love.graphics.newFont(path, size)
    end

    return font
end
