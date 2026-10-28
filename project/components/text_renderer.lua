local c = {}

c.FONTS = {}

c.draw = function(v, p)
    local font_name, font_size = p.font, math.clamp(p.font_size, 1, 999)

    if not c.FONTS[font_name] then
        c.FONTS[font_name] = {}
    end
    if not c.FONTS[font_name][tostring(font_size)] then
        local fonts_dir = "project/fonts/"
        if love.filesystem.getInfo(fonts_dir .. font_name) then
            c.FONTS[font_name][tostring(font_size)] = lg.newFont(fonts_dir .. font_name, font_size)
        else
            return
        end
    end

    local x, y = 0, 0

    local w, h = c.getRawDimensions(v, p)
    local cw, ch = v.size.x, v.size.y
    if p.center_h then x = math.floor(cw/2 - w/2) end
    if p.center_v then y = math.floor(ch/2 - h/2) end

    lg.push()
    lg.setFont(c.FONTS[font_name][tostring(font_size)])
    lg.push()

    local ox, oy = p.shadow_offset[1], p.shadow_offset[2]
    if ox ~= 0 or oy ~= 0 then
        lg.saveColor()
        lg.setColor(p.shadow_color[1], p.shadow_color[2], p.shadow_color[3], p.shadow_color[4])
        lg.print(p.text, x + ox, y + oy)
        lg.revertColor()
    end

    lg.pop()
    lg.print(p.text, x, y)
    lg.pop()
end

c.getRawDimensions = function(v, p)
    local font_name, font_size = p.font, p.font_size

    if c.FONTS[font_name] and c.FONTS[font_name][tostring(font_size)] then
        local font = c.FONTS[font_name][tostring(font_size)]

        return font:getWidth(p.text), font:getHeight()
    end
    return 0, 0
end

c.getDimensions = function(v, p)
    local rw, rh = c.getRawDimensions(v, p)

    if p.center_h then
        rw = v.size.x
    end
    if p.center_v then
        rh = v.size.y
    end

    return rw, rh
end

------------------- Load -------------------

function c.load()
    MakeComponent("TextRenderer", {
        font = {"BricolageGrotesque.ttf", "string", "Font"},
        font_size = { 24, "number", "Font Size" },
        text = { "Hello, world!", "string", "Text" },
        center_h = {false, "bool", "Center H"},
        center_v = {false, "bool", "Center V"},
        shadow_offset = {{0, 0}, "number2", "Shadow Offset"},
        shadow_color = {{0, 0, 0, 0.4}, "color4", "Shadow Color"}
    }, {
        draw = c.draw,
        getDimensions = c.getDimensions
    })
end

return c
