
local textLib = {}
local language

function getTKey(key)
    return textLib[key] or key
end

function getLang()
    return language
end

function readTexts(lang)
    language = lang
    local rLang = readTextFile(lang)
    local gLang = readTextFile("global")
    local langs = table.merge({rLang, gLang})
    textLib = langs
    --table.print(textLib)
    --print(getTKey("MENU_CONTINUE"))
end

function readTextFile(name)
    local textFolder = getData("projectMeta")["dirs"]["text"]
    local textLines = love.filesystem.lines("project/"..textFolder.."/"..name..".str")

    local lang = name
    local langKeys = {}

    local i = 1
    for l in textLines do
        if i == 1 then
            lang = l
        else
            local parts = l:split(":")
            local key, value = "", ""

            key = parts[1]
            key = key:strip(" ")
            key = key:lstrip("\"")
            key = key:rstrip("\"")
            --print("'"..key.."'")

            value = parts[2]
            value = value:lstrip(" ")
            value = value:lstrip("\"")
            value = value:rstrip("\"")
            --print("'"..value.."'")

            --print("'"..key.."'"..": ".."'"..value.."'")
            langKeys[key] = value

        end
        i=i+1
    end

    --print(lang.." table: ")
    --table.print(langKeys)

    return langKeys, lang
end
