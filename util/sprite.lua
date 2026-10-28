function LoadSprite(path)
    SetSprite(path, lg.newImage("project/images/"..path))
end

function MakeMissing(w, h)
    w, h = w or 64, h or 64

    local canvas = lg.newCanvas(w, h)
    lg.setCanvas(canvas)
    lg.clear(0, 0, 0, 0)

    lg.setColor(1, 0, 1, 1)
    lg.rectangle("fill", 0, 0, w, h)

    lg.setColor(0, 0, 0, 1)
    lg.rectangle("fill", 0, h/2, w/2, h/2)

    lg.rectangle("fill", w/2, 0, w/2, h/2)

    lg.setCanvas()
    lg.setColor(1, 1, 1, 1)

    return canvas
end

function GetSpriteFullpath(path)
    local t = type(path)
    local fullpath
    if t ~= "table" then
        if t == "string" then
            fullpath = path
        else
            return nil
        end
    else
        fullpath = table.concat(path, "\\")
    end
    return fullpath
end

function IsSpritePath(path)
    local fullpath = GetSpriteFullpath(path)
    return SPRITES[fullpath]
end

function GetSprite(path)
    local fullpath = GetSpriteFullpath(path)
    local sprite = SPRITES[fullpath]
    if sprite then return sprite else serror("GetSprite(path): Sprite does not exist! (fullpath: " .. fullpath .. ")") return SPRITES["missing"] end
end

function SetSprite(path, object)
    local fullpath = GetSpriteFullpath(path)
    if fullpath then SPRITES[fullpath] = object else serror("Incorrect path! (fullpath: " .. fullpath .. ")") end
end
