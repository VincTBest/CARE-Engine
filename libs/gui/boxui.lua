require("libs.gui.generic")

local BOX = {} -- BoxUI

BOX.DATA = { version = "0.0.0", author = "VincTBest", name = "BoxUI" }

-- Assets

BOX.ASSETS = {}
BOX.ASSETS.BOX = love.graphics.newImage("libs/gui/assets/boxui/box.png")
BOX.ASSETS.BOXSLICE = createNineSlice(BOX.ASSETS.BOX, 8)

-- Elements

BOX.ELEMENTS = {}

BOX.elType = { -- Constants
    BUTTON = "eltype:button", LABEL = "eltype:label", SUBGRID = "eltype:layer"
}

function BOX.CreateEl(elType, px, py, sx, sy)
    px, py, sx, sy = px or 0, py or 0, sx or 1, sy or 1

    local id = #BOX.ELEMENTS + 1
    local el = {
        elType = elType, pos = { px, py }, size = { sx, sy }
    }

    table.insert(BOX.ELEMENTS, el)

    return id
end

function BOX.GetEl(id)
    return BOX.ELEMENTS[id]
end

function BOX.SetEl(el, id)
    BOX.ELEMENTS[id] = el
end

-- Config

BOX.GridSizeW = 32
BOX.GridSizeH = 32

-- Helpers

function BOX.getElTrueTransform(el)
    local x, y, w, h = el.pos[1], el.pos[2], el.size[1], el.size[2]
    local gw, gh = BOX.GridSizeW,BOX.GridSizeH
    return x*gw, y*gh, w*gw, h*gh
end

function BOX.getElGridTransform(x, y, w, h)
    local gw, gh = BOX.GridSizeW,BOX.GridSizeH
    x, y = math.floor(x / gw), math.floor(y / gh)
    w, h = math.floor(w / gw), math.floor(h / gh)
    return x, y, w, h
end

-- Draw

function BOX.DrawGrid(sx, sy, cw, ch, ox, oy)
    ox, oy = ox or 0, oy or 0 -- Offsets

    local cols = math.ceil(cw / sx)
    local rows = math.ceil(ch / sy)

    for c = 1, cols do
        c = c - 1
        love.graphics.line(c*sx, 0, c*sx, ch)
    end

    for r = 1, rows do
        r = r - 1
        love.graphics.line(0, r*sy, cw, r*sy)
    end

end

BOX.DRAWERS = {}
BOX.DRAWERS[BOX.elType.LABEL] = function(el, id)
    local x, y, w, h = BOX.getElTrueTransform(el)
    setColor(1, 1, 1, 1)
    --rect("fill", x, y, w, h, 4)
    BOX.ASSETS.BOXSLICE.draw(x, y, w, h) -- Freezes window
end

function BOX.DrawEl(el, id)
    local Drawer = BOX.DRAWERS[el.elType]
    if Drawer then
        Drawer(el, id)
    else
        print("elType not found for el with id "..tostr(id).."! (draw)", el.elType)
    end
end

function BOX.DrawEls()
    local ww, wh = love.window.getMode()
    setColor(.6, .6, .6, .8)

    local gw, gh = BOX.GridSizeW, BOX.GridSizeH
    BOX.DrawGrid(gw, gh, ww, wh)

    for i=1,#BOX.ELEMENTS do
        BOX.DrawEl(BOX.ELEMENTS[i], i)
    end
end

return BOX
