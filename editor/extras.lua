
local imgui = require "cimgui"
local ffi   = require "ffi"

local e = {}
e.snap = {
    pos = 1,
    rot = 10,
    size = .1
}
e.sel = {
    outline = true
}
e.ctx = {
    tryRun = false,
    run = false,
    noWarn = false
}

e.sceneSaveName = "Untitled Scene"

function e.draw()
    local window_size = imgui.ImVec2_Float(160,180)
    local padding = 15

    imgui.SetNextWindowPos(imgui.ImVec2_Float(padding, padding), imgui.ImGuiCond_Always)
    --imgui.SetNextWindowSize(window_size, imgui.ImGuiCond_Always);

    if imgui.Begin("Config", nil, imgui.ImGuiWindowFlags_AlwaysAutoResize) then
        imgui.SeparatorText("Snap")
        for k, v in pairs(e.snap) do
            local value = ffi.new("float[1]", v)
            imgui.PushItemWidth(window_size.x)
            if imgui.DragFloat(k, value, .1) then
                e.snap[k] = value[0]
            end
            imgui.PopItemWidth()
        end
        imgui.SeparatorText("Selected")
        for k, v in pairs(e.sel) do
            local value = ffi.new("bool[1]", v)
            imgui.PushItemWidth(window_size.x)
            if imgui.Checkbox(k, value) then
                e.sel[k] = value[0]
            end
            imgui.PopItemWidth()
        end
        imgui.SeparatorText("Context")

        local value
        value = ffi.new("bool[1]", e.ctx.run)
        if imgui.Checkbox("Simulate Run", value) then
            e.ctx.run = value[0]
        end

        value = ffi.new("bool[1]", e.ctx.noWarn)
        if imgui.Checkbox("NoWarn", value) then
            e.ctx.noWarn = value[0]
        end

        imgui.SeparatorText("Scene")
        imgui.SetNextItemWidth(window_size.x)

        local initial_name = (e.sceneSaveName and #e.sceneSaveName > 0) and e.sceneSaveName or ""
        local name = ffi.new("char[64]")
        ffi.copy(name, initial_name, math.min(#initial_name, 63))
        if imgui.InputText("Scene Name", name, 64) then
            e.sceneSaveName = ffi.string(name)
        end

        local path = "scene_" .. e.sceneSaveName .. ".json"

        if imgui.Button("Save") then
        	local data = { objects = OBJECTS }
        	local ok, encoded = pcall(json.encode, data)
        	if ok then
        		local success, err = love.filesystem.write(path, encoded)
        		if not success then print("Mentési hiba: " .. tostring(err)) end
        	else
        		print("JSON error: " .. tostring(encoded))
        	end
        end

        imgui.SameLine()

        if imgui.Button("Load") then
           	if love.filesystem.getInfo(path) then
          		local contents = love.filesystem.read(path)
          		local ok, scene = pcall(json.decode, contents)

          		if ok and scene and scene.objects then
         			OBJECTS = scene.objects
         			SelectedIdx = 0
         			RebuildObjectNames()
          		else
         			print("Loading error: " .. tostring(scene))
          		end
           	else
          		print("Scene not found: " .. path)
           	end
        end

        imgui.SameLine()

        if imgui.Button("Clear") then
            OBJECTS = {}
            RebuildObjectNames()
        end
    end
    imgui.End()

    window_size = Vec2(680, 90)

    local vp = imgui.GetMainViewport();
    local pos_x = vp.WorkPos.x + (vp.WorkSize.x/2 - window_size.x/2)
    local pos_y = vp.WorkPos.y + (vp.WorkSize.y - window_size.y - padding)

    imgui.SetNextWindowPos(Vec2(pos_x, pos_y), imgui.ImGuiCond_Always)
    imgui.SetNextWindowSize(window_size, imgui.ImGuiCond_Always);
    imgui.SetNextWindowBgAlpha(0.3)

    local WARN = false
    local WARN_l1 = "Line 1"
    local WARN_l2 = "Line 2"

    if not Running(true) and e.ctx.tryRun and not e.ctx.noWarn then
        WARN = true
        WARN_l1 = "An object is trying to update itself, but the game is not running!"
        WARN_l2 = "Enable Config > Context > Simulate Run for the object to run itself, or Config > Context > NoWarn to hide this."
    end

    local flags = bit.bor(
        imgui.ImGuiWindowFlags_NoBackground,
        imgui.ImGuiWindowFlags_NoDecoration,
        imgui.ImGuiWindowFlags_NoTitleBar,
        imgui.ImGuiWindowFlags_NoCollapse,
        imgui.ImGuiWindowFlags_NoScrollbar,
        imgui.ImGuiWindowFlags_NoResize,
        imgui.ImGuiWindowFlags_NoMove
    )

    local childFlags = bit.bor(
        imgui.ImGuiChildFlags_AlwaysUseWindowPadding,
        imgui.ImGuiChildFlags_Borders
    )

    local childBg = imgui.ImVec4_Float(0.8, 0.7, 0.3, 0.3)
    local border = imgui.ImVec4_Float(0.8, 0.7, 0.5, 0.8)

    if WARN then
        if imgui.Begin("Warning##ee-warn-tryRun", nil, flags) then
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ChildBg, childBg)
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Border, border)
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Text, border)

            if imgui.BeginChild_Str("Warning", nil, childFlags) then
                imgui.Text(WARN_l1)
                imgui.Text(WARN_l2)
                imgui.EndChild()
            end

            imgui.PopStyleColor()
            imgui.PopStyleColor()
            imgui.PopStyleColor()
        end
        imgui.End()
    end

end

function e.update()

end

return e
