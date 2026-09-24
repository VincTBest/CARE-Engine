
-- Tables

TILESETS = {}
MAPS = {}

-- Maps

function loadTiledMaps()

end

function loadTiledMap(path)
    local mapsDir = getData("projectMeta")["dirs"]["maps"]
    local fileRaw = love.filesystem.read("project/" .. mapsDir .. "/" .. path .. ".tmj")

    --local mapNameSep = "."
    --local mapNameSpl = path:split(mapNameSep)
    --local mapName = table.concat(mapNameSpl, mapNameSep, 1, #mapNameSpl - 1)
    local mapName = path

    --print("Loading map: "..mapNameSep)
    --table.print(mapNameSpl)
    print("Loading map: "..mapName..".tmj")

    local file = json.decode(fileRaw)
    --table.print(file)

    local data = {}
    local mW, mH = file["width"], file["height"]
    --print("w/h", mW, mH)
    local tW, tH = file["tilewidth"], file["tileheight"]
    data.width, data.height = mW, mH
    data.tWidth, data.tHeight = tW, tH

    data.layers = {}
    for i = 1, #file["layers"] do
        local layer = file["layers"][i]
        local obj = { data = create2DArray(mW, mH, 0) }
        obj.data.forEach(function(_, x, y)
            return layer["data"][(x - 1) + (y - 1) * mW + 1]
        end)
        obj.name, obj.type, obj.vis, obj.id = layer["name"], layer["type"], layer["visible"], layer["id"]
        table.insert(data.layers, obj)
    end

    --table.print(data.layers)

    data.tilesets = {}
    for i = 1, #file["tilesets"] do
        local ts = file["tilesets"][i]
        local obj = { source = ts["source"], firstgid = ts["firstgid"] }

        data.tilesets[ts["source"]] = obj
    end

    --return data
    MAPS[mapName] = data
    return mapName
end

function createTilemap(data)
    local obj = {}

    obj.data = data
    --print("w/h OD.x", obj.data.width, obj.data.height)
    --print("w/h LD.x", obj.data.layers[1].data.width, obj.data.layers[1].data.height)
    --print("w/h LD.xs", obj.data.layers[1].data.w, obj.data.layers[1].data.h)
    --table.print(obj)

    function obj.draw(xO, yO)
        xO, yO = xO or 0, yO or 0

        local tilesets = obj.data.tilesets
        local tW, tH = obj.data.tWidth, obj.data.tHeight

        local sortedTilesets = {}
       	for k, v in pairs(tilesets) do
      		table.insert(sortedTilesets, { name = k, firstgid = v.firstgid })
       	end
        table.sort(sortedTilesets, function(a, b) return a.firstgid > b.firstgid end)

        for x = 1,obj.data.width do
            for y = 1, obj.data.height do
                --print(type(obj.data.layers))
                --table.print(obj.data.layers)
                for l = 1, #obj.data.layers do
                    local gid = obj.data.layers[l].data.get(x, y)
    				if not gid or gid == 0 then goto continue end

    				local tileset, fgid
    				for _, ts in ipairs(sortedTilesets) do
    					if gid >= ts.firstgid then
    						tileset, fgid = ts.name, ts.firstgid
    						break
    					end
    				end
    				if not tileset then goto continue end

    				local id = gid - fgid
    				local tsn = tileset:gsub("%.tsj", "")
    				local quads = TILESETS[tsn].quads
    				local qid = math.clamp(id + 1, 1, #quads)

    				love.graphics.draw(TILESETS[tsn].image, quads[qid], (x-1)*tW+xO, (y-1)*tH+yO)

    				::continue::
                end
            end
        end
    end

    return obj
end

-- Tilesets

function loadTiledTilesets()
    local mapsDir = getData("projectMeta")["dirs"]["maps"]
    local files = love.filesystem.getDirectoryItems("project/"..mapsDir.."/")

    for i=1,#files do
        local filename = files[i]
        if filename:endswith(".tsj") then
            loadTiledTileset(filename)
        end
    end
end

function loadTiledTileset(path)
    local mapsDir = getData("projectMeta")["dirs"]["maps"]
    local fileRaw = love.filesystem.read("project/" .. mapsDir .. "/" .. path)

    print("Loading tileset: " .. path)

    local file = json.decode(fileRaw)

    local tsName = file["name"]

    local imagePath = file["image"]
    --local image = love.graphics.newImage("project/"..mapsDir.."/"..imagePath)
    local imagePathFull = normalizePath(joinPath("project", mapsDir, imagePath))
    --print(imagePathFull)

    print("Loading tileset image: " .. imagePathFull)

    local image = love.graphics.newImage(imagePathFull)

    local tw, th = file["tilewidth"], file["tileheight"]
    local iw, ih = file["imagewidth"], file["imageheight"]
    local cols, rows = file["columns"] or iw/tw , file["rows"] or ih/th
    table.print(file)
    --local margin, spacing = file["margin"], file["spacing"]

    local obj = {
        imagePath = imagePath,
        image = image,
        tilewidth = tw,
        tileheight = th,
        cols = cols,
        rows = rows,
        name = tsName,
        --margin = margin, spacing = spacing, -- Unused
        quads = getTilesetQuads(cols, rows, tw, th),
    }

    TILESETS[tsName] = obj
    return tsName
end

function getTilesetQuads(cols, rows, tw, th)
    local iW, iH = cols * tw, rows * th
    local quads = {}
    for y = 1, rows do
    	for x = 1, cols do
    		local quad = love.graphics.newQuad((x - 1) * tw, (y - 1) * th, tw, th, iW, iH)
    		table.insert(quads, quad)
    	end
    end
    return quads
end
