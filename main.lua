io.stdout:setvbuf("no")

require("util.all")
require("editor.core")
local e = require("editor.extras")

EnableEditor = false
EnableDebug = false
G_RUNNING = false
TICK = 0
OBJECTS = {}
SPRITES = {}
HIGHLIGHTS = {}

function Running(noWarn)
    if not noWarn then
        e.ctx.tryRun = true
    end
    return G_RUNNING or e.ctx.run
end

function Editor()
    return not Running(true)
end

------------------- love.load -------------------

function love.load(arg, unfilteredArg)
    love.filesystem.setIdentity("LoveEngine")
    love.window.setMode(1920 * 9 / 10, 1080 * 9 / 10)
    love.window.setTitle("CARE Engine")

    EnableEditor = table.contains(arg, "--editor")
    EnableDebug = table.contains(arg, "--debug")

    if EnableEditor then
        print("Starting Editor...")
        love.window.setTitle("CARE Engine | Editor")
        lLoad(arg, unfilteredArg)
    end
    print("CARE Engine Version " .. CARE_VERSION)

    --print("Rad-Deg conversion test (10).")
    for i = 1, 10 do
        local deg = math.random(0, 360 * 100) / 100 -- Random number from 0 to 360 with 3 decimal places
        local rad = deg_to_rad(deg)
        --print(tostr(deg == rad_to_deg(rad)).." (deg(generated): "..tostr(deg)..", rad(converted):"..tostr(rad)..", deg(converted): "..tostr(rad_to_deg(rad))..")")
    end

    print("Loading components...")
    LoadComponents()

    print("Loading sprites...")
    lg.setDefaultFilter("linear")

    LoadSprite("O.png")
    LoadSprite("wiki.png")
    SetSprite("missing", MakeMissing(64, 64))
    --SetSprite("missingHD", MakeMissing(1024, 1024))
end

------------------- Objects : Update -------------------

function UpdateObjects(dt)
    SetProcessingObjU(nil)
    for i, v in ipairs(OBJECTS) do
        SetProcessingObjU(i)
        if v.update then
            OBJECTS[i] = v.update(dt) or v
        else
            for _, c in ipairs(v.components) do
                local comp = COMPONENTS[c.id]
                if comp.funcs.update then
                    OBJECTS[i] = comp.funcs.update(v, c.params) or v
                end
            end
        end
    end
    SetProcessingObjU(nil)
end

function love.update(dt)
    UpdateObjects(dt)
    if EnableEditor then
		lUpdate(dt)
	else
    end

    --print(love.timer.getFPS())
    TICK = TICK + 1
end

------------------- Objects : Draw -------------------

function GraphicsTranslateRotate(v)
    local ww, wh = v.size.x, v.size.y
    local isSprite = IsSpritePath(v.sprite)
    local sprite
    if isSprite then
        sprite = GetSprite(v.sprite)
        ww, wh = sprite:getDimensions()
        ww, wh = ww * v.size.x, wh * v.size.y
    end

    local offset

    local compSizes = { w = {}, h = {} }
    for _, c in ipairs(v.components) do
        local comp = COMPONENTS[c.id]
        if comp.funcs.getDimensions then
            local w, h, ox, oy = comp.funcs.getDimensions(v, c.params)
            table.insert(compSizes.w, w)
            table.insert(compSizes.h, h)
            if ox then
                offset = Vec2(ox, oy)
            end
        end
    end

    local cw = table.getBiggest(compSizes.w)
    local ch = table.getBiggest(compSizes.h)

    if #compSizes.w > 0 then
        ww, wh = cw, ch
    end

    local tx, ty = 0, 0
    if v.rot_anchor.x == 1 then
        tx = ww / 2
    elseif v.rot_anchor.x == 2 then
        tx = ww
    end

    if v.rot_anchor.y == 1 then
        ty = wh / 2
    elseif v.rot_anchor.y == 2 then
        ty = wh
    end

    lg.translate(v.pos.x + tx, v.pos.y + ty)
    lg.rotate(deg_to_rad(v.rot))
    lg.translate(-tx, -ty)

    return ww, wh, offset
end

function AddHighlight(x, y, w, h, color, colordark, offset)
    table.insert(HIGHLIGHTS, {
        x, y, w, h, color, colordark or {0, 0, 0}, offset or 0
    })
end

function DrawHighlight(x, y, w, h, color, colordark, offset)
    lg.push()
    local c = lg.getColorRS()

    local size = 4
    lg.origin()
    lg.translate(x, y)
    lg.translate(-size, -size)

    local alpha = (0.5 + math.sin(TICK / 100) / 2) + offset

    lg.setLineWidth(size / 2 * 1.5)
    lg.setColor(colordark[1], colordark[2], colordark[3], alpha)
    lg.rectangle("line", 0, 0, w + (size * 2), h + (size * 2), 4)

    lg.setLineWidth(size / 2)
    lg.setColor(color[1], color[2], color[3], alpha)
    lg.rectangle("line", 0, 0, w + (size * 2), h + (size * 2), 4)

    c.restore()
    lg.pop()
end

function DrawHighlights()
    for i = #HIGHLIGHTS, 1, -1 do
        local v = HIGHLIGHTS[i]

        local x, y, w, h, color, colordark, offset = v[1], v[2], v[3], v[4], v[5], v[6], v[7]
        DrawHighlight(x, y, w, h, color, colordark, offset)

        table.remove(HIGHLIGHTS, i)
    end
    HIGHLIGHTS = {}
end

function DrawObjects()
    SetProcessingObjD(nil)
    for i, v in ipairs(OBJECTS) do
        SetProcessingObjD(i)
        if v.draw then
            OBJECTS[i] = v.draw() or v
        else
            lg.push()

            local ww, wh, offset = GraphicsTranslateRotate(v)

            lg.push()
            if e.sel.outline and SelectedIdx == i then
                local x, y = v.pos.x, v.pos.y
                if offset then x, y = x+offset.x, y+offset.y end
                AddHighlight(x, y, ww, wh, {1, 1, 0}, {0, 0, 0})
            end
            lg.pop()

            lg.setColor(v.color.x, v.color.y, v.color.z, v.color.w)
            if v.default_draw then
                lg.rectangle("fill", 0, 0, v.size.x, v.size.y)
            end

            for _, c in ipairs(v.components) do
                local comp = COMPONENTS[c.id]
                if comp.funcs.draw then
                    OBJECTS[i] = comp.funcs.draw(v, c.params) or v
                end
            end

            lg.setColor(1, 1, 1, 1)
            lg.pop()
        end
    end
    DrawHighlights()
    SetProcessingObjD(nil)
end

function love.draw(...)
    DrawObjects()
    if EnableEditor then
        lDraw(...)
    else

        --drawDefaultCanvas(0, 0)

        lg.setColor(1, 1, 1, 1)
        lg.print("FPS: " .. tostr(love.timer.getFPS()))
        --clear(1,1,1,1)
        --mapD.draw()
    end
end

------------------- Love Callbacks (For ImGui) -------------------

function love.mousepressed( x, y, button, istouch, presses )
    if EnableEditor then
		lMousepressed( x, y, button, istouch, presses )
	end
end

function love.mousereleased(x, y, button, istouch, presses)
    if EnableEditor then
        lMousereleased(x, y, button, istouch, presses)
    end
end

function love.mousemoved(...)
	if EnableEditor then
		lMousemoved(...)
	end
end

function love.wheelmoved(...)
	if EnableEditor then
		lWheelmoved(...)
	end
end

function love.keypressed(...)
	if EnableEditor then
		lKeypressed(...)
	end
end

function love.keyreleased(...)
	if EnableEditor then
		lKeyreleased(...)
	end
end

function love.textinput(...)
	if EnableEditor then
		lTextinput(...)
	end
end

function love.focus(...)
	if EnableEditor then
		lFocus(...)
	end
end

function love.quit(...)
	if EnableEditor then
		return lQuit(...)
	end
end

function love.joystickadded(...)
	if EnableEditor then
		lJoystickadded(...)
	end
end

function love.joystickremoved(...)
	if EnableEditor then
		lJoystickremoved(...)
	end
end

function love.gamepadpressed(...)
	if EnableEditor then
		lGamepadpressed(...)
	end
end

function love.gamepadreleased(...)
	if EnableEditor then
		lGamepadreleased(...)
	end
end

function love.gamepadaxis(...)
	if EnableEditor then
		lGamepadaxis(...)
	end
end
