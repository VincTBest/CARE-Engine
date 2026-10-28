
local imgui = require "cimgui"
local ffi    = require "ffi"

local M = {}

M.names = { "Light", "Dark" }
M.current = 1

-- bg, child, popup, border, frame, frameHover, frameActive,
-- accent, accentHover, accentActive, text, textDim
local P = {
	Light = {0xEFEFEF, 0xDADBDD, 0xD8D9DB, 0x9B8DAB, 0xA4A8AC, 0xADB3B9, 0xB6BEC6,
	                0x0c96ab, 0x1aa4b8, 0x0FB5CF, 0x3B4752, 0x6B7782},
	Dark  = {0x000000, 0x0A0B0D, 0x08090B, 0x1C2024, 0x14181C, 0x1D2329, 0x262E36,
	                0x22D3EE, 0x5DE4F7, 0x0FB5CF, 0xF1F5F8, 0x6B7782}
}

local function setColor(style, name, rgb, a)
	local idx = imgui["ImGuiCol_" .. name]
	if idx == nil then return end
	local c = style.Colors[idx]
	c.x = bit.band(bit.rshift(rgb, 16), 0xFF) / 255
	c.y = bit.band(bit.rshift(rgb, 8), 0xFF) / 255
	c.z = bit.band(rgb, 0xFF) / 255
	c.w = a or 1
end

local function setVec2(v, x, y)
	v.x, v.y = x, y
end

function M.apply(which)
	local name = type(which) == "number" and M.names[which] or which
	local p = P[name]
	assert(p, "ismeretlen téma: " .. tostring(which))
	for i, n in ipairs(M.names) do
		if n == name then M.current = i end
	end

	local bg, child, popup, border = p[1], p[2], p[3], p[4]
	local frame, fHover, fActive = p[5], p[6], p[7]
	local accent, aHover, aActive = p[8], p[9], p[10]
	local text, textDim = p[11], p[12]

	local s = imgui.GetStyle()

	--
	setVec2(s.WindowPadding, 12, 12)
	setVec2(s.FramePadding, 10, 6)
	setVec2(s.CellPadding, 8, 5)
	setVec2(s.ItemSpacing, 10, 8)
	setVec2(s.ItemInnerSpacing, 8, 6)
	setVec2(s.WindowTitleAlign, 0.5, 0.5)
	s.IndentSpacing = 20
	s.ScrollbarSize = 12
	s.GrabMinSize = 12

	--
	s.WindowRounding = 6
	s.ChildRounding = 6
	s.PopupRounding = 6
	s.FrameRounding = 4
	s.ScrollbarRounding = 8
	s.GrabRounding = 3
	s.TabRounding = 8

	--
	s.WindowBorderSize = 1
	s.ChildBorderSize = 1
	s.PopupBorderSize = 1
	s.FrameBorderSize = 1
	s.TabBorderSize = 1

	--
	local function col(n, rgb, a) setColor(s, n, rgb, a) end

	col("Text", text)
	col("TextDisabled", textDim)
	col("WindowBg", bg)
	col("ChildBg", child)
	col("PopupBg", popup, 0.98)
	col("Border", border)
	col("BorderShadow", 0x000000, 30/255)

	col("FrameBg", frame)
	col("FrameBgHovered", fHover)
	col("FrameBgActive", fActive)

	col("TitleBg", bg)
	col("TitleBgActive", child)
	col("TitleBgCollapsed", bg, 0.8)
	col("MenuBarBg", child)

	col("ScrollbarBg", bg, 0)
	col("ScrollbarGrab", fHover)
	col("ScrollbarGrabHovered", fActive)
	col("ScrollbarGrabActive", accent)

	col("CheckMark", accent)
	col("SliderGrab", accent)
	col("SliderGrabActive", aActive)

	col("Button", frame)
	col("ButtonHovered", aHover, 0.85)
	col("ButtonActive", aActive)

	col("Header", 0x32B3CE, 0.25)
	col("HeaderHovered", accent, 0.55)
	col("HeaderActive", accent, 0.80)

	col("Separator", border)
	col("SeparatorHovered", aHover)
	col("SeparatorActive", aActive)

	col("ResizeGrip", accent, 0.20)
	col("ResizeGripHovered", accent, 0.60)
	col("ResizeGripActive", accent, 0.90)

	--
	col("Tab", child)
	col("TabHovered", aHover, 0.80)
	col("TabSelected", accent, 0.90)
	col("TabActive", accent, 0.90)
	col("TabSelectedOverline", aHover)
	col("TabDimmed", child)
	col("TabUnfocused", child)
	col("TabDimmedSelected", fHover)
	col("TabUnfocusedActive", fHover)

	col("DockingPreview", accent, 0.60)
	col("DockingEmptyBg", bg)

	col("PlotLines", aHover)
	col("PlotLinesHovered", aActive)
	col("PlotHistogram", accent)
	col("PlotHistogramHovered", aHover)

	col("TableHeaderBg", child)
	col("TableBorderStrong", border)
	col("TableBorderLight", border, 0.5)
	col("TableRowBg", 0x000000, 0)
	col("TableRowBgAlt", frame, 0.25)

	col("TextLink", aHover)
	col("TextSelectedBg", accent, 0.40)
	col("TreeLines", border)
	col("DragDropTarget", aHover)
	col("NavCursor", aHover)
	col("NavHighlight", aHover)
	col("NavWindowingHighlight", 0xFFFFFF, 0.7)
	col("NavWindowingDimBg", 0x000000, 0.5)
	col("ModalWindowDimBg", 0x000000, 0.55)
end

function M.picker()
    local changed = false

    local vp = imgui.GetMainViewport();
    local window_size = imgui.ImVec2_Float(250,110)
    local padding = 15
    local pos_x = vp.WorkPos.x + vp.WorkSize.x - window_size.x - padding

    imgui.SetNextWindowPos(imgui.ImVec2_Float(pos_x, padding), imgui.ImGuiCond_Always)
    --imgui.SetNextWindowSize(window_size, imgui.ImGuiCond_Always);
    if imgui.Begin("Theme", nil, imgui.ImGuiWindowFlags_AlwaysAutoResize) then
        imgui.SetNextItemWidth(window_size.x-10*2-16)
        if imgui.BeginCombo(" ", M.names[M.current]) then
            for i, n in ipairs(M.names) do
                if imgui.Selectable_Bool(n, M.current == i) then
                    M.apply(i)
                    changed = true
                end
            end
            imgui.EndCombo()
        end
	end
	imgui.End()
	return changed
end

return M
