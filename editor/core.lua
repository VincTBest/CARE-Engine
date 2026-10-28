-- Make sure the shared library can be found through package.cpath before loading the module.
-- For example, if you put it in the LÖVE save directory, you could do something like this:
local lib_path = love.filesystem.getWorkingDirectory()
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)

local ffi = require("ffi")
local imgui = require("cimgui")
local themes = require("editor.themes")
local editor_extras = require("editor.extras")
local object_man = require("editor.object_man")

local hu_ranges = ffi.new("ImWchar[5]", { 0x0020, 0x00FF, 0x0100, 0x017F, 0 })
local fonts = {}

------------------- love.load -------------------

lLoad = function(_arg, _unfilteredArg)
    imgui.love.Init()
    local io = imgui.GetIO()

	local dir = love.filesystem.getSource() .. "/project/fonts/"

	fonts.main = io.Fonts:AddFontFromFileTTF(dir .. "BricolageGrotesque.ttf", 16, nil, hu_ranges)

    themes.apply(1)
end

function HelpMarker(desc)
    imgui.TextDisabled("(?)")
    if imgui.BeginItemTooltip() then
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35)
        imgui.TextUnformatted(desc)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

OBJECTS_NAMES = {}
OBJECTS = {}
COMPONENTS = {}
SelectedIdx = 0
ComponentsSelIdx = 0
ProcessedObjD = 0
ProcessedObjU = 0

------------------- Components : Functions -------------------

function MakeComponent(name, params, funcs)
    local id = #COMPONENTS + 1
    local comp = {
        name = name,
        params = params,
        funcs = funcs
    }
    table.insert(COMPONENTS, comp)
    return id
end

function AddCompObj(idx, c_idx)
	local def = COMPONENTS[c_idx]
	local comp = {
		id = c_idx,
		params = {},
	}

    for key, v in pairs(def.params) do
        if type(v) == "table" then
            comp.params[key] = v[1]
        else
            comp.params[key] = v
        end
	end

	table.insert(OBJECTS[idx].components, comp)
end

function RemCompObj(idx, c_idx)
    local comps = OBJECTS[idx].components
    for i = #comps, 1, -1 do
        if comps[i].id == c_idx then
            table.remove(comps, i)
        end
    end
end

function LoadComponent(name)
    local component = require("project.components." .. tostr(name))
    if component and component.load then
        component.load()
    end
end

function LoadComponents()
    local dir = "project/components/"
    local items = love.filesystem.getDirectoryItems(dir)
    for _, v in ipairs(items) do
        v = tostring(v)
        if not stringx.endswith(v, ".lua") then
            break
        end

        local name = stringx.rstrip(v, ".lua")
        print("Loading component: "..name)
        LoadComponent(name)
    end
end

------------------- Components : Basic Components -------------------

MakeComponent("SpriteRenderer", {
    sprite_path = { "O.png", "string", "Sprite" }, -- {default_value, expected_type, label}
    pos_offset  = { { 0, 0 }, "number2", "Offset" },
}, {
    draw = function(v, p)
        lg.push()

        --graphicsTranslateRotate(v)

        local sprite = GetSprite(p.sprite_path)

        lg.setColor(v.color.x, v.color.y, v.color.z, v.color.w)
        if sprite then
            lg.draw(sprite, p.pos_offset[1], p.pos_offset[2], 0, v.size.x, v.size.y)
        end
        lg.setColor(1, 1, 1, 1)
        lg.pop()
    end,
    update = nil,
    getDimensions = function(v, p)
        local ww, wh = 0, 0

        local sprite = GetSprite(p.sprite_path)
        if sprite then
            ww, wh = sprite:getDimensions()
            ww, wh = ww * v.size.x, wh * v.size.y
        end

        return ww, wh
    end
})

ShapeDrawOnce = function(shape, mode, w, h, r)
    if shape == 1 then
        lg.rectangle(mode, 0, 0, w, h, r, r)
    elseif shape == 2 then
        lg.ellipse(mode, 0 + w / 2, 0 + h / 2, w / 2, h / 2)
    elseif shape == 3 then
        lg.circle(mode, 0, 0, r)
    end
end

MakeComponent("ShapeRenderer", {
    shape_type = {1, {"rectangle", "ellipse", "circle"}, "Shape"},
    mode = { 1, { "fill", "line" }, "Mode" },
    radius = {10, "number", "Radius"},
    smoothen = { true, "bool", "Smoothen" },
    thickness = { 2, "number", "Line Thickness" }
}, {
    draw = function(v, p)
        local mode = "fill"
        if p.mode == 2 then mode = "line" end

        lg.push()
        lg.setLineWidth(p.thickness)
        if p.smoothen and mode == "fill" then
            ShapeDrawOnce(p.shape_type, "line", v.size.x, v.size.y, p.radius)
        end
        ShapeDrawOnce(p.shape_type, mode, v.size.x, v.size.y, p.radius)

        lg.pop()
    end,
    getDimensions = function(v, p)
        local w, h = v.size.x, v.size.y
        local o

        if p.shape_type == 3 then
            w, h = p.radius*2, p.radius*2
            o = -p.radius
        end

        return w, h, o, o
    end
})

MakeComponent("WASDController", {
    speed = {2.0, "number", "Speed"}
}, {
    update = function(v, p)
        local l, r, u, d = love.keyboard.isDown("a"), love.keyboard.isDown("d"), love.keyboard.isDown("w"), love.keyboard.isDown("s")
        local dx, dy = 0, 0
        if l then dx = dx - p.speed end
        if r then dx = dx + p.speed end
        if u then dy = dy - p.speed end
        if d then dy = dy + p.speed end
        if Running() then
            v.pos = Vec2(v.pos.x+dx, v.pos.y+dy)
        end
    end
})

MakeComponent("DebugTest", {
    test_n1 = {20, "number", "number"},
    test_n2 = {{3.8, 32.1}, "number2", "number2"},
    test_n3 = {{13.5, 43.1, 83.2}, "number3", "number3"},
    test_str = {"Hello, world!", "string", "string"},
    test_bool = {false, "bool", "bool"},
    test_dropdown = {1, {"AAAA", "bbbb", "CCCC", "dddd", "EEEE", "ffff", "GGGG"}, "dropdown"},
    test_color3 = {{245, 12, 16}, "color3", "color3"},
    test_color4 = {{183, 64, 125, 194}, "color4", "color4"},
}, {draw=nil, update=nil, getDimensions=nil})

------------------- Objects : Functions -------------------

function ObjIndexBounds(index)
    if #OBJECTS < index then
        error("Object index out of bounds!")
    end
end

function AddObj(name)
    name = name or "unnamed"
    local time = UnixTS()
    local obj = {
        uts = time,
        rot = 0,
        rot_anchor = Vec2(1, 1), -- Center, middle
        pos = Vec2(350, 300),
        size = Vec2(1, 1),
        color = Vec4(1, 1, 1, 1),
        sprite = nil,
        tags = "",
        name = name,
        default_draw = true,
        components = {},
    }
    table.insert(OBJECTS, obj)
    table.insert(OBJECTS_NAMES, name)
end

function RemObj(idx)
    table.remove(OBJECTS, idx)
    table.remove(OBJECTS_NAMES, idx)
end

function MoveObj(idx, a)
    local new_idx = math.clamp(1, idx + a, #OBJECTS)
    if new_idx == idx then return idx end

    local obj = table.remove(OBJECTS, idx)
    table.insert(OBJECTS, new_idx, obj)
    RebuildObjectNames()
    return new_idx
end

function DupeObj(idx)
    local obj = OBJECTS[idx]
    local new_obj = table.deepcopy(obj)
    new_obj.name = new_obj.name .. " (2)"
    table.insert(OBJECTS, idx+1, new_obj)
    RebuildObjectNames()
end

function RebuildObjectNames()
    OBJECTS_NAMES = {}
    for _, v in ipairs(OBJECTS) do
        table.insert(OBJECTS_NAMES, v.name)
    end
end

function SetProcessingObjD(index)
    ProcessedObjD = index
end

function GetProcessingObjD()
    return ProcessedObjD
end

function SetProcessingObjU(index)
    ProcessedObjU = index
end

function GetProcessingObjU()
    return ProcessedObjU
end

------------------- Objects : Tags -------------------

function ObjIndexBounds(index)
	if type(index) ~= "number" or index < 1 or index > #OBJECTS then
		error("Object index out of bounds: " .. tostring(index), 3)
	end
end

local function splitTag(t)
	local k, v = t:match("^([^=]+)=?(.*)$")
	if v == "" then v = nil end
	return k, v
end

local function saveTags(index, tags)
	OBJECTS[index].tags = table.concat(tags, " ")
end

function ObjGetTags(index)
	ObjIndexBounds(index)
	local str = OBJECTS[index].tags or ""
	local tags = {}
	for t in str:gmatch("%S+") do
		tags[#tags + 1] = t
	end
	return tags, str
end

function ObjHasTag(index, tag)
	for _, t in ipairs(ObjGetTags(index)) do
		if (splitTag(t)) == tag then
			return true, t
		end
	end
	return false
end

function ObjAddTag(index, tag)
	local name = splitTag(tag)
	if not name or ObjHasTag(index, name) then return false end
	local tags = ObjGetTags(index)
	table.insert(tags, tag)
	saveTags(index, tags)
	return true
end

function ObjRemTag(index, tag)
	local tags = ObjGetTags(index)
	for i = #tags, 1, -1 do
		if (splitTag(tags[i])) == tag then
			table.remove(tags, i)
		end
	end
	saveTags(index, tags)
end

function ObjGetTagV(index, tag)
	local has, t = ObjHasTag(index, tag)
	if not has then return nil end
	local _, v = splitTag(t)
	return v -- always a string, use tonumber() if needed
end

function ObjSetTagV(index, tag, value)
	local tags = ObjGetTags(index)
	local new = tag .. "=" .. tostring(value)
	for i, t in ipairs(tags) do
		if (splitTag(t)) == tag then
			tags[i] = new
			saveTags(index, tags)
			return
		end
	end
	table.insert(tags, new)
	saveTags(index, tags)
end

------------------- love.draw -------------------

lDraw = function()
    imgui.ShowDemoWindow()

    object_man.draw()

    themes.picker()
    editor_extras.draw()

    -- Render ImGui
    imgui.Render()
    imgui.love.RenderDrawLists()
end

------------------- Love Callbacks -------------------

lUpdate = function(dt)
	imgui.love.Update(dt)

	local io = imgui.GetIO()
	local w, h = love.graphics.getDimensions()
	io.DisplaySize = imgui.ImVec2_Float(w, h)

	editor_extras.update()
	imgui.NewFrame()
end

lMousemoved = function(x, y, ...)
    imgui.love.MouseMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here
    end
end

lMousepressed = function(x, y, button, ...)
    imgui.love.MousePressed(button)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here
    end
end

lMousereleased = function(x, y, button, ...)
    imgui.love.MouseReleased(button)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here
    end
end

lWheelmoved = function(x, y)
    imgui.love.WheelMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here
    end
end

lKeypressed = function(key, ...)
    imgui.love.KeyPressed(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        -- your code here
    end
end

lKeyreleased = function(key, ...)
    imgui.love.KeyReleased(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        -- your code here
    end
end

lTextinput = function(t)
    imgui.love.TextInput(t)
    if imgui.love.GetWantCaptureKeyboard() then
        -- your code here
    end
end

lFocus = function(f)
    imgui.love.Focus(f)
end

lQuit = function()
    return imgui.love.Shutdown()
end

-- for gamepad support also add the following:

lJoystickadded = function(joystick)
    imgui.love.JoystickAdded(joystick)
    -- your code here
end

lJoystickremoved = function(joystick)
    imgui.love.JoystickRemoved()
    -- your code here
end

lGamepadpressed = function(joystick, button)
    imgui.love.GamepadPressed(button)
    -- your code here
end

lGamepadreleased = function(joystick, button)
    imgui.love.GamepadReleased(button)
    -- your code here
end

-- choose threshold for considering analog controllers active, defaults to 0 if unspecified
local threshold = 0.2

lGamepadaxis = function(joystick, axis, value)
    imgui.love.GamepadAxis(axis, value, threshold)
    -- your code here
end
