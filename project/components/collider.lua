local e = require("editor.extras")
local c = {}

c.COLLIDERS = {}

function c.drawCollider(obj, params)
    if not Editor() then return end
    if GetProcessingObjD() ~= SelectedIdx then return end
    if not e.sel.outline then return end

    lg.push()
    local x, y, w, h, _ox, _oy = c.getCollider(obj, params)
    AddHighlight(x, y, w, h, {.14, .03, .8}, {.21, .09, .7}, 0)
    AddHighlight(x, y, w, h, {.14, .03, .8}, {.21, .09, .7}, 0.5)

    lg.pop()
end

function c.getCollider(obj, params)
    local w, h = params.dimensions[1], params.dimensions[2]
    local ox, oy = params.offset[1], params.offset[2]
    local x, y = obj.pos.x, obj.pos.y

    return x + ox, y + oy, w, h, ox, oy
end

function c.updateCollider(obj, params)
    local collider = c.COLLIDERS[params.id]

    if not collider then
        collider = {
            pos = Vec2(0, 0),
            size = Vec2(0, 0),
            shape = "rect",
        }
    end

    local x, y, w, h = c.getCollider(obj, params)
    collider.pos = Vec2(x, y)
    collider.size = Vec2(w, h)
end

------------------- Load -------------------

function c.load()
    MakeComponent("Collider", {
        shape = {1, {"Rectangle"}, "Collider Shape"},
        group = {1, "number", "Collision Group"},
        dimensions = {{64, 64}, "number2", "Dimensions"},
        offset = {{0, 0}, "number2", "Offset"},
        id = {"Id", "string", "Identifyer"},
    }, {
        draw = c.drawCollider,
        update = c.updateCollider
    })

    MakeComponent("Collider", {
        shape = {1, {"Rectangle"}, "Collider Shape"},
        group = {1, "number", "Collision Group"},
        dimensions = {{64, 64}, "number2", "Dimensions"},
        offset = {{0, 0}, "number2", "Offset"},
        id = {"Id", "string", "Identifyer"},
    }, {
        draw = c.drawCollider,
        update = c.updateCollider
    })

end

return c
