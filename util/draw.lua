
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
    love.graphics.setFont(getFontObj(font, size))
end

function getFontObj(font, size)
    size = tostr(size)
    if not table.containsK(font, size) then
        error("Font does not have size "..size.."!\n")
        return
    end
    return font[size]
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

function draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
    x = x or 0
    y = y or 0
    x, y = applyCamera(x, y)
    love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
end

-- 9-slice

function createNineSlice(img, borderSize)
    local ns = {}

    local iw, ih = img:getDimensions()

    local b = borderSize

    local quads = {
        topLeft     = love.graphics.newQuad(0, 0, b, b, iw, ih),
        top         = love.graphics.newQuad(b, 0, iw - b * 2, b, iw, ih),
        topRight    = love.graphics.newQuad(iw - b, 0, b, b, iw, ih),

        left        = love.graphics.newQuad(0, b, b, ih - b * 2, iw, ih),
        center      = love.graphics.newQuad(b, b, iw - b * 2, ih - b * 2, iw, ih),
        right       = love.graphics.newQuad(iw - b, b, b, ih - b * 2, iw, ih),

        bottomLeft  = love.graphics.newQuad(0, ih - b, b, b, iw, ih),
        bottom      = love.graphics.newQuad(b, ih - b, iw - b * 2, b, iw, ih),
        bottomRight = love.graphics.newQuad(iw - b, ih - b, b, b, iw, ih)
    }

    local function drawTiled(quad, x, y, w, h, tileW, tileH)
        if w <= 0 or h <= 0 then
            return
        end

        local _, _, qw, qh = quad:getViewport()

        tileW = tileW or qw
        tileH = tileH or qh

        local rows = math.ceil(h / tileH)
        local cols = math.ceil(w / tileW)

        for row = 0, rows - 1 do
            for col = 0, cols - 1 do
                local dw = math.min(tileW, w - col * tileW)
                local dh = math.min(tileH, h - row * tileH)

                if dw > 0 and dh > 0 then
                    local sx = dw / tileW
                    local sy = dh / tileH

                    love.graphics.draw(img, quad, x + col * tileW, y + row * tileH, 0, sx, sy)
                end
            end
        end
    end

    function ns.draw(x, y, w, h)
        if w < b * 2 or h < b * 2 then
            return
        end

        local centerW = w - b * 2
        local centerH = h - b * 2

        -- Corners: never stretched.
        love.graphics.draw(img, quads.topLeft, x, y)
        love.graphics.draw(img, quads.topRight, x + w - b, y)
        love.graphics.draw(img, quads.bottomLeft, x, y + h - b)
        love.graphics.draw(img, quads.bottomRight, x + w - b, y + h - b)

        -- Edges: tiled in their respective directions.
        drawTiled(quads.top, x + b, y, centerW, b)

        drawTiled(quads.bottom, x + b, y + h - b, centerW, b)

        drawTiled(quads.left, x, y + b, b, centerH)

        drawTiled(quads.right, x + w - b, y + b, b, centerH)

        drawTiled(quads.center, x + b, y + b, centerW, centerH)
    end

    return ns
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
    path = normalizePath(joinPath("project/"..getData("projectMeta")["dirs"]["fonts"], path))
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

-- Canvas

function setCanvas(canvas, mipmap)
    canvas = canvas or DEFAULT_CANVAS
    if canvas == "n" then canvas = nil end
    return love.graphics.setCanvas(canvas, mipmap)
end

function getCanvas(...)
    return love.graphics.getCanvas(...)
end

function newCanvas(...)
    return love.graphics.newCanvas(...)
end

DEFAULT_CANVAS = newCanvas(1, 1)
local CANVAS_IMAGEDATA
--setCanvas(DEFAULT_CANVAS)

function updateDefaultCanvas()
    local Ww, Wh = love.window.getMode()
    if Ww ~= DEFAULT_CANVAS:getWidth() or Wh ~= DEFAULT_CANVAS:getHeight() then
        DEFAULT_CANVAS = newCanvas(Ww, Wh)
    end
end

function drawDefaultCanvas(cxo, cyo)
    local cw, ch = DEFAULT_CANVAS:getDimensions()
    local pX, pY = getCamera()
    setCamera(0, 0)

    readyCanvasPasses()

    --doCanvasPass(function(v, x, y) return { x / cw, y / ch, 0, 1 } end)
    doCanvasPass(function(v, x, y)
        local r, g, b = v[1], v[2], v[3]

        --print(r, g, b, v[4], x, y)

        return {r/2, g/2, b/2, 1}
    end)

    finishCanvasPasses(0, 0)

    --draw(DEFAULT_CANVAS, cxo, cyo)
    setCamera(pX, pY)
end

function doCanvasPass(func)
    CANVAS_IMAGEDATA:mapPixel(function(x, y, r, g, b, a)
        local tbl = func({ r, g, b, a }, x, y)
        --print(r, g, b, a, x, y)
        return tbl[1], tbl[2], tbl[3], tbl[4] or a
    end)
end

function readyCanvasPasses()
    CANVAS_IMAGEDATA = DEFAULT_CANVAS:newImageData(nil,1,0,0,DEFAULT_CANVAS:getWidth(),DEFAULT_CANVAS:getHeight())
end

function finishCanvasPasses(cxo, cyo)
	local image = love.graphics.newImage(CANVAS_IMAGEDATA)

    setCanvas("n")

    setColor(1, 1, 1, 1)
	draw(image, cxo or 0, cyo or 0)
end
