require("util.math")
require("util.other")
require("util.sprite")
stringx = require("pl.stringx")
json = require("util.json")

CARE_CREDITS = {
    {"CARE Engine", "VincTBest"},
    {"Other", "Penlight"}
}

CARE_VERSION = "0.1"

lg = love.graphics

local savedColor = {}
lg.saveColor = function()
    local r, g, b, a = lg.getColor()
    savedColor = { r, g, b, a }
end

lg.revertColor = function()
    local r, g, b, a = savedColor[1], savedColor[2], savedColor[3], savedColor[4]
    lg.setColor(r, g, b, a)
end

lg.getColorRS = function()
    local c = {}

    local r, g, b, a = lg.getColor()
    c.color = Vec4(r, g, b, a)

    c.restore = function()
        local r, g, b, a = c.color.x, c.color.y, c.color.z, c.color.w
        lg.setColor(r, g, b, a)
    end

    return c
end
