
local imgui = require "cimgui"
local ffi   = require "ffi"
local editor_extras = require("editor.extras")
local obj_man = {}

local vp
local window_size = imgui.ImVec2_Float(500, 750)
local padding = 15
local pos_x, pos_y

local move_idx, move_dir

function obj_man.drawListbox()
    if imgui.BeginListBox("##objects", Vec2(window_size.x - 10 * 2, imgui.GetTextLineHeightWithSpacing() * 8)) then
        for n = 1, #OBJECTS_NAMES do
            imgui.PushID_Int(n)

            local is_selected = (SelectedIdx == n)
            local overlap = imgui.ImGuiSelectableFlags_AllowOverlap
                         or imgui.ImGuiSelectableFlags_AllowItemOverlap
                         or 0

            if imgui.Selectable_Bool(tostring(OBJECTS_NAMES[n]), is_selected, overlap) then
                SelectedIdx = n
            end
            imgui.SameLine()
            imgui.TextDisabled("(#" .. tostr(n) .. ")")
            imgui.SameLine()
    		if imgui.SmallButton("^") then move_idx, move_dir = n, -1 end
    		imgui.SameLine()
    		if imgui.SmallButton("v") then move_idx, move_dir = n, 1 end

            imgui.PopID()
        end
        imgui.EndListBox()
    end
end

function obj_man.draw()
    move_idx, move_dir = nil, nil

    vp = imgui.GetMainViewport();
    pos_x = vp.WorkPos.x + vp.WorkSize.x - window_size.x - padding
    pos_y = vp.WorkPos.y + vp.WorkSize.y - window_size.y - padding

    imgui.SetNextWindowPos(imgui.ImVec2_Float(pos_x, pos_y), imgui.ImGuiCond_Always)
    imgui.SetNextWindowSize(window_size, imgui.ImGuiCond_Always);

    if imgui.Begin("Objects", nil, nil) then

        obj_man.drawListbox()

        if move_idx then
            local new_idx = MoveObj(move_idx, move_dir)
            if SelectedIdx == move_idx then SelectedIdx = new_idx end
        end

        if imgui.Button("Add Object") then
            AddObj("New Object " .. tostr(#OBJECTS + 1))
        end
        imgui.SameLine()
        imgui.BeginDisabled(SelectedIdx == 0)
        if imgui.Button("Remove Object") then
            --if SelectedIdx >= (#OBJECTS_NAMES - 1) then SelectedIdx = SelectedIdx - 1 end
            RemObj(SelectedIdx)
        end
        imgui.SameLine()
        if imgui.Button("Duplicate") then
            DupeObj(SelectedIdx)
        end
        imgui.SameLine()
        if imgui.Button("Unselect") then
            SelectedIdx = 0
        end
        imgui.EndDisabled()
        imgui.SameLine()
        imgui.Text(tostr(#OBJECTS_NAMES) .. " Object(s)")

        local obj = OBJECTS[SelectedIdx]
        if not obj and SelectedIdx ~= 0 then
            SelectedIdx = #OBJECTS
            obj = OBJECTS[SelectedIdx]
        end
        if SelectedIdx > 0 and obj then
            imgui.Text("Selected: " .. tostr(obj.name))
            imgui.SameLine()
            imgui.TextDisabled("(#" .. tostr(SelectedIdx) .. ")")

            if imgui.BeginChild_Str("Scrollable", nil, imgui.ImGuiChildFlags_AlwaysUseWindowPadding) then
                imgui.Text("Object Creation: " .. tostr(UnixTSToTime(obj.uts)))
                imgui.SameLine()
                HelpMarker("Unix Timestamp: "..tostr(obj.uts))

                local initial_name = (obj.name and #obj.name > 0) and obj.name or ""
                local name = ffi.new("char[64]")
                ffi.copy(name, initial_name, math.min(#initial_name, 63))
                if imgui.InputText("Name", name, 64) then
                    obj.name = ffi.string(name)
                    OBJECTS_NAMES[SelectedIdx] = obj.name
                end


                local initial_tags = (obj.tags and #obj.tags > 0) and obj.tags or ""
                local tags = ffi.new("char[128]")
                ffi.copy(tags, initial_tags, math.min(#initial_tags, 127))
                if imgui.InputText("Tags", tags, 128) then
                    obj.tags = ffi.string(tags)
                end

                local position = ffi.new("float[2]", { obj.pos.x, obj.pos.y })
                if imgui.DragFloat2("Position", position, editor_extras.snap.pos) then
                    obj.pos = Vec2(position[0], position[1])
                end

                local size = ffi.new("float[2]", { obj.size.x, obj.size.y })
                if imgui.DragFloat2("Size", size, editor_extras.snap.size) then
                    obj.size = Vec2(size[0], size[1])
                end

                local color = ffi.new("float[4]", { obj.color.x, obj.color.y, obj.color.z, obj.color.w })
                if imgui.ColorEdit4("Color", color) then
                    obj.color = Vec4(color[0], color[1], color[2], color[3])
                end

                local rot = ffi.new("float[1]", obj.rot)
                if imgui.DragFloat("Rotation (Degrees)", rot, editor_extras.snap.rot) then
                    obj.rot = rot[0] % 360
                end

                local h_anchor = ffi.new("int[1]", obj.rot_anchor.x)
                imgui.RadioButton_IntPtr("Left", h_anchor, 0)
                imgui.SameLine()
                imgui.RadioButton_IntPtr("Center", h_anchor, 1)
                imgui.SameLine()
                imgui.RadioButton_IntPtr("Right", h_anchor, 2)
                imgui.SameLine()
                imgui.TextDisabled("Horizontal Rotation Anchor: " .. tostr(h_anchor[0]))

                local v_anchor = ffi.new("int[1]", obj.rot_anchor.y)
                imgui.RadioButton_IntPtr("Top", v_anchor, 0)
                imgui.SameLine()
                imgui.RadioButton_IntPtr("Middle", v_anchor, 1)
                imgui.SameLine()
                imgui.RadioButton_IntPtr("Bottom", v_anchor, 2)
                imgui.SameLine()
                imgui.TextDisabled("Vertical Rotation Anchor: " .. tostr(v_anchor[0]))

                obj.rot_anchor = Vec2(h_anchor[0], v_anchor[0])

                local default_draw = ffi.new("bool[1]", obj.default_draw)
                if imgui.Checkbox("default_draw", default_draw) then
                    obj.default_draw = default_draw[0]
                end

                imgui.SeparatorText("Components")

                local default_value
                if ComponentsSelIdx == 0 then
                    default_value = "Select a component"
                else
                    default_value = COMPONENTS[ComponentsSelIdx].name
                end

                if imgui.BeginCombo("Components", default_value) then
                    for n = 1, #COMPONENTS do
                        local is_selected = ComponentsSelIdx == n

                        if imgui.Selectable_Bool(tostring(COMPONENTS[n].name), is_selected) then
                            ComponentsSelIdx = n
                        end

                        if is_selected then
                            imgui.SetItemDefaultFocus()
                        end
                    end
                    imgui.EndCombo()
                end
                imgui.BeginDisabled(ComponentsSelIdx == 0)
                if imgui.Button("Add") then
                    AddCompObj(SelectedIdx, ComponentsSelIdx)
                end
                imgui.EndDisabled()

                for i, c in ipairs(obj.components) do
                    local def = COMPONENTS[c.id]

                    imgui.PushID_Int(i)
                    imgui.SeparatorText("Component: " .. tostr(def.name))
                    imgui.SameLine()
                    if imgui.SmallButton("x") then
                        table.remove(obj.components, i)
                        imgui.PopID()
                        break
                    end

                    for pk, pv in pairs(c.params) do
                        local o = def.params[pk]
                        if type(o) == "table" then
                            if o[2] == "string" then
                                local initial_val = (pv and #pv > 0) and pv or ""
                                local val = ffi.new("char[64]")
                                ffi.copy(val, initial_val, math.min(#initial_val, 63))
                                if imgui.InputText(o[3], val, 64) then
                                    pv = ffi.string(val)
                                end
                            elseif o[2] == "number" then
                                local val = ffi.new("float[1]", pv)
                                if imgui.DragFloat(o[3], val, 0.1) then
                                    pv = val[0]
                                end
                            elseif o[2] == "number2" then
                                local val = ffi.new("float[2]", pv)
                                if imgui.DragFloat2(o[3], val, 0.1) then
                                    pv = { val[0], val[1] }
                                end
                            elseif o[2] == "number3" then
                                local val = ffi.new("float[3]", pv)
                                if imgui.DragFloat3(o[3], val, 0.1) then
                                    pv = { val[0], val[1], val[2] }
                                end
                            elseif o[2] == "color3" then
                                local val = ffi.new("float[3]", pv)
                                if imgui.ColorEdit3(o[3], val) then
                                    pv = { val[0], val[1], val[2] }
                                end
                            elseif o[2] == "color4" then
                                local val = ffi.new("float[4]", pv)
                                if imgui.ColorEdit4(o[3], val) then
                                    pv = { val[0], val[1], val[2], val[3] }
                                end
                            elseif o[2] == "bool" then
                                local val = ffi.new("bool[1]", pv)
                                if imgui.Checkbox(o[3], val) then
                                    pv = val[0]
                                end
                            elseif type(o[2]) == "table" then
                                local items = o[2]
                                local idx   = math.max(1, math.min(tonumber(pv) or 1, #items))

                                if imgui.BeginCombo(o[3], tostring(items[idx])) then
                                    for i = 1, #items do
                                        local is_selected = (i == idx)
                                        if imgui.Selectable_Bool(tostring(items[i]) .. "##" .. i, is_selected) then
                                            pv = i
                                        end
                                        if is_selected then
                                            imgui.SetItemDefaultFocus()
                                        end
                                    end
                                    imgui.EndCombo()
                                end
                            end
                            c.params[pk] = pv
                        end
                    end

                    imgui.PopID()
                end
            end
            imgui.EndChild()
        else
            SelectedIdx = 0
            imgui.TextDisabled("Add or select an object.")
        end
    end
    imgui.End()
end

return obj_man
