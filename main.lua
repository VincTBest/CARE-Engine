-- CARE Engine:  A data-driven Love2D game engine.
require("util.all")

function getCareCredits()
    return CARE_CREDITS
end

dataKeys = {}
data = {}
function addData(name, value) data[name] = value table.insert(dataKeys, name) end
function getData(name) return data[name] or nil end
function hasData(name) return getData(name) ~= nil end

scripts = {}
activeScripts = {}
function loadScripts()
    local scriptFolder = getData("projectMeta")["dirs"]["scripts"]
    local files = love.filesystem.getDirectoryItems("project/"..scriptFolder.."/")

    for i=1,#files do
        local filename = files[i]
        local file = love.filesystem.read("project/"..scriptFolder.."/"..filename)
        scripts[filename] = file
    end
end
function loadScript(filename)
    local source = scripts[filename]
    if not source then
        error("Script not found: " .. filename)
    end

    local environment = {}
    setmetatable(environment, {
        __index = _G
    })

    local chunk, err = loadstring(source, "@" .. filename)
    if not chunk then
        error(err)
    end
    setfenv(chunk, environment)

    local success, result = pcall(chunk)
    if not success then
        error(result)
    end

    if environment.sLoad then environment.sLoad() end

    return environment
end
function runScript(filename)
    local environment = loadScript(filename)

    if environment.sRun then environment.sRun() end

    table.insert(activeScripts, environment)
end

function love.load()
    print("CARE Engine")

    -- local l = createColliderLayer()
    -- createCollider(l, "square", 250, 100, 110, 140)
    -- createCollider(l, "circle", 300, 300, 100)

    print("Loading game...")

    local project_meta_json = love.filesystem.read("project/project.json")
    local project_meta = json.decode(project_meta_json)
    addData("projectMeta", project_meta)

    print("Loading texts...")

    readTexts("EN-US")

    print("Loading scripts...")
    loadScripts()

    local game_title = project_meta.title
    local game_version = project_meta.version

    print("Starting "..game_title.." "..game_version.."!")
    love.window.setTitle(game_title)

    runScript(project_meta["mainScript"])

    table.print(data)
end

function forFuncInScripts(funcname, ...)
    for i = 1, #activeScripts do
        local script = activeScripts[i]

        if script[funcname] then
            script[funcname](...)
        end
    end
end

function love.update(dt)
    forFuncInScripts("sUpdate", dt)

    --print(love.timer.getFPS())
end

function love.draw()
    clear()

    forFuncInScripts("sDraw")
end

function love.mousepressed( x, y, button, istouch, presses )
    forFuncInScripts("sMousePressed", x, y, button, istouch, presses)
end

function love.mousereleased( x, y, button, istouch, presses )
    forFuncInScripts("sMouseReleased", x, y, button, istouch, presses)
end
