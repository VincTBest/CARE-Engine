print("Hello from script")

local demoImage
local wikiImage
local demoFont

local mx, my = 0, 0 -- Mouse Coords
local ww, wh = 0, 0 -- Window W/H

local xr = 0 -- Extra Radius

local sine = 0
local t, s, sf = 0, 0, 0 -- Ticks, seconds, seconds floored

function transformX(x) return x*-1+ww end
function transformY(y) return y*-1+wh end

function sLoad()
    print("Load!")

    demoImage = loadImage("O.png")
    wikiImage = loadImage("wiki.png")
    demoFont = loadFonts("NotoSans-Regular.ttf")
end

function sRun()
    print("Run!")
    print(getCareCredits())
end

local cx, cy = 0, 0

function sDraw()

    clear(sine, sine, sine, 1)

    setColor(1, 0, 0, .1)

    switchCamera(1)
    setCamera(cx, cy)

    circleFill(400, 300, 200+xr*1.5)
    circle(400, 300, 200+xr*1.5)

    setColor(0, 0, 1, .075)

    circleFill(580, 210, 180+xr*1.4)
    circle(580, 210, 180+xr*1.4)

    setColor(0, 1, 0, .8)

    local f = 10
    local tx, ty = mx / f, my / f
    circleFill(400+tx, 300+ty, 200+xr*1.5)
    circle(400+tx, 300+ty, 200+xr*1.5)

    setColor(0, 0, 1, .4)
    circleFill(mx, my, 50+xr)
    circle(mx, my, 50+xr)

    tx, ty = transformX(mx), transformY(my)
    setColor(1, 0, 0, .3)
    circleFill(tx, ty, 60+xr*1.1)
    circle(tx, ty, 60+xr*1.1)

    -- Images
    --switchCamera(2)

    setColor(1, 1, 1, 1)

    draw(demoImage, ww-16-64, 16)

    -- FPS Counter

    setColor(1,1,1,.6)

    setFont(demoFont, 14)
    local cameraN, cameraX, cameraY = getCamera(1)
    text("FPS: "..tostr(love.timer.getFPS())..", Cam: "..tostr(cameraN).."; "..tostr(cameraX).."; "..tostr(cameraY), 2, 2)
end

function sUpdate(dt)
    mx, my = love.mouse.getPosition()
    ww, wh = love.window.getMode()

    sine = math.sin(s) / 100 * 10

    s = s + dt
    sf = math.floor(s * 100) / 100
    t = t + 1
    if xr < 0 then
        xr = math.clamp(xr + (0.35*(xr*-1)/10), -99, 0)
    else
        xr = math.clamp(xr - (0.35*xr/10), 0, 99)
    end

    local spd = 1
    if love.keyboard.isDown("w") then cy = cy + spd end
    if love.keyboard.isDown("s") then cy = cy - spd end
    if love.keyboard.isDown("a") then cx = cx + spd end
    if love.keyboard.isDown("d") then cx = cx - spd end

    if sf % .5 == 0 then xr = xr + .85 end
    if sf % 2 == 0 then xr = xr + 1 end
    if sf % 1 == 0 then xr = xr + 1.5 end
end

function sMousePressed(_x, _y, _button, _istouch, _presses)
    xr = xr + 8
end

function sMouseReleased(_x, _y, _button, _istouch, _presses)
    xr = xr - (4 - xr)
end
