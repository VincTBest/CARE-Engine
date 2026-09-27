local gui = require("libs.gui.inc")
local box = gui.boxui

local TestLabel
local mx, my

function sLoad()
    --print("Load!")

    TestLabel = box.CreateEl(box.elType.LABEL, 0, 0, 1, 1)
end

function sRun()
    --print("Run!")
end

function sDraw()
    clear(0, 0, 0, 1)

    box.DrawEls()
end

function sUpdate(dt)
    mx, my = love.mouse.getPosition()
    local label = box.GetEl(TestLabel)
    label.size[1] = mx / 32
    label.size[2] = my / 32
    box.SetEl(label, TestLabel)
end

function sMousePressed(_x, _y, _button, _istouch, _presses)
end

function sMouseReleased(_x, _y, _button, _istouch, _presses)
end
