--[[ SDSetup Homebrew App ]]--

-- FUNCTION CLASSES
local Utils = require("Utils")
local Http = require("socket.http")
local Json = require("json")


-- COMPONENT CLASSES
require 'components/Page'
require 'components/Image'
require 'components/Label'
require 'components/Card'
require 'components/StackCard'
require 'components/Checkbox'
require 'components/Button'
require 'components/Animation'

-- EVENT SUBSCRIPTIONS

SubscribeUpdate = {}
SubscribeAfterUpdate = {}

-- INIT GLOBAL VARS

APP_VERSION = "alpha v0.3"

components = {}

blacklistedIds = {
    "section_retroarch",
    "section_extras",
    "subcategory_homebrew_emulators_bundles",
    "package_checkbox_sdsetup-app"
}

drawCallback = nil
drawCallbackReady = false
drawNeedsCallback = false

show = false

cursorX = 640
cursorY = 360
showCursor = false
allowCursor = true
axisValues = {leftx = 0, lefty = 0, rightx = 0, righty = 0 }




-- MAIN
function GenerateComponents()

    

    --local body = love.filesystem.read("manifest.json")
    local body, code = Http.request("http://files.sdsetup.com/api/v1/fetch/manifest/sdsetupapp/" .. packageset)
    local manifest = Json.parse(body)

    packageItems = {}
    packageCheckboxes = {}
    local sections = {}

    table.insert(sections, Image("logo", "logo", "res/logo.png", 0, 0, 1, 1))
    table.insert(sections, Label("label_version", APP_VERSION, 0, 340, 1280, 40, 20, {0,0,0,1}, "center"))

    for _,secid in pairs(manifest["Platforms"]["switch"]["PackageSections"]["_keys"]) do
        local sec = manifest["Platforms"]["switch"]["PackageSections"]["_values"][secid] --workaround, ordered_table is bugged in lovepotion for some reason

        if Utils.TableContains(blacklistedIds, "section_" .. sec["ID"]) == false then
            local sectionChildren = {}
            table.insert(sectionChildren, Card("section_spacer_" .. sec["ID"], "", 0, 0, 1, 10, {0,0,0,0}, {0,0,0,0}, {}))
            table.insert(sectionChildren, Label("section_label_" .. sec["ID"], sec["DisplayName"], 0, 0, 1020, 35, 28, {0,0,0,1}, "center"))
            
            local categories = {}
            if sec["ListingMode"] == 0 then
                for _,catid in pairs(sec["Categories"]["_keys"]) do
                    local cat = sec["Categories"]["_values"][catid]

                    local categoryChildren = {}
                    table.insert(categoryChildren, Card("category_spacer_" .. cat["ID"], "", 0, 0, 1, 10, {0,0,0,0}, {0,0,0,0}, {}))
                    table.insert(categoryChildren, Label("category_label_" .. sec["ID"] .. "_" .. cat["ID"], cat["Name"], 5, 0, 1280, 33, 26, {0,0,0,1}))

                    local subcategories = {}
                    for _,subid in pairs(cat["Subcategories"]["_keys"]) do
                        local sub = cat["Subcategories"]["_values"][subid]
                        if Utils.TableContains(blacklistedIds, "subcategory_" .. sec["ID"] .. "_" .. cat["ID"] .. "_" .. sub["ID"]) == false then
                            local subcategoryChildren = {}
                            table.insert(categoryChildren, Label("subcategory_label_" .. sec["ID"] .. "_" .. cat["ID"] .. "_" .. sub["ID"], sub["Name"], 8, 0, 1280, 28, 22, {0,0,0,1}))

                            local packages = {}
                            local packs = 0

                            for _,packid in pairs(sub["Packages"]["_keys"]) do
                                local pack = sub["Packages"]["_values"][packid]
                                if Utils.TableContains(blacklistedIds, "package_checkbox_" .. pack["ID"]) == false then
                                    table.insert(packageItems, pack)
                                    if pack["Visible"] then
                                        --table.insert(subcategoryChildren, Label(, , 10, 0, 1280, 28, 20, {0,0,0,1}))
                                        local pcbxText = pack["DisplayName"] .. " (" .. pack["Versions"]["latest"] .. ")"
                                        local pcbx = Checkbox("package_checkbox_" .. pack["ID"], pcbxText, 10, 0, 1280, 28, 20, 20, 5, {0,0,0,1}, {1,1,1,1}, {0.87450980392, 0.87450980392, 0.87450980392, 0.87450980392}, pack["EnabledByDefault"], pack)
                                        table.insert(categoryChildren, pcbx)
                                        table.insert(packageCheckboxes, pcbx)
                                    end
                                end
                                
                            end

                            --table.insert(categoryChildren, StackCard("subcategory_" .. sec["ID"] .. "_" .. cat["ID"] .. "_" .. sub["ID"] , sub["Name"], 12, 0, 304, 720, false, {0,0,0,0}, {0,0,0,0}, 5, subcategoryChildren))
                        end
                    end
                    table.insert(categories, StackCard("category_" .. sec["ID"] .. "_" .. cat["ID"], cat["Name"], 4, 0, 486, 720, false, {1,1,1,1}, {0.8, 0.8, 0.8, 1}, 5, categoryChildren))
                end

                for i=0,table.maxn(categories),2 do
                    local row = {}
                    local maxY = 0
                    for n=0,1 do
                        if (categories[i+n+1] ~= nil) then
                            local curCat = categories[i+n+1]
                            curCat.x = 8 + (30 + 486) * n
                            if curCat.dy > maxY then maxY = curCat.dy end
                            table.insert(row, curCat)
                        end
                    end
                    for n=1,2 do
                        if (row[n] ~= nil) then
                            row[n].dy = maxY
                            row[n]:ResetCanvas()
                        end
                    end

                    if #row > 0 then
                        table.insert(sectionChildren, row)
                    end
                end

                table.insert(sections, StackCard("section_" .. sec["ID"], sec["Name"], 130, 0, 1020, 720, false, {1,1,1,1}, {0.8, 0.8, 0.8, 1}, 5, sectionChildren))
            else
                local packages = {}
                
                
                for _,catid in pairs(sec["Categories"]["_keys"]) do
                    local cat = sec["Categories"]["_values"][catid]
                    for _,subid in pairs(cat["Subcategories"]["_keys"]) do
                        local sub = cat["Subcategories"]["_values"][subid]
                        for _,packid in pairs(sub["Packages"]["_keys"]) do
                            local pack = sub["Packages"]["_values"][packid]
                            if pack["Visible"] then
                                table.insert(packages, pack)
                            end
                        end
                    end
                end
                love.graphics.setFont(FontFromStorage(20))
                for i=0,table.maxn(packages),2 do
                    local row = {}
                    local maxY = 0
                    for n=0,1 do
                        if (packages[i+n+1] ~= nil) then
                            local pack = packages[i+n+1]
                            local x = 5 + (501 * n)
                            --table.insert(row, Label("package_label_" .. pack["ID"], pack["DisplayName"], x, 0, 501, 28, 20, {0,0,0,1}, "center"))
                            local pcbxText = pack["DisplayName"] .. " (" .. pack["Versions"]["latest"] .. ")"
                            local pcbx = Checkbox("package_checkbox_" .. pack["ID"], pcbxText, 500 - (love.graphics.getFont():getWidth(pcbxText) / 2) - (5 / 2), 0, 501, 28, 20, 20, 5, {0,0,0,1}, {1,1,1,1}, {0.87450980392, 0.87450980392, 0.87450980392, 0.87450980392}, pack["EnabledByDefault"], pack)
                            table.insert(sectionChildren, pcbx)
                            --table.insert(row, pcbx)
                            table.insert(packageCheckboxes, pcbx)
                        end
                    end
                    if #row > 0 then
                        table.insert(sectionChildren, Card("row_" .. secid .. "_" .. (i/2), "", 4, 0, 1007, 28, {0,0,0,0}, {0,0,0,0}, row))
                    end
                end
                table.insert(sections, StackCard("section_" .. sec["ID"] , sec["Name"], 130, 0, 1020, 720, false, {1,1,1,1}, {0.8, 0.8, 0.8, 1}, 5, sectionChildren))
            end
        end
    end

    table.insert(sections, Button("button_dl", "Download Files", 128, 0, 1024, 70, 30, {1,1,1,1}, {0.85882352941,0.15686274509,0.15686274509,1}, {0,0,0,0}, DownloadPressed))
    table.insert(sections, Button("button_exit", "Exit App", 128, 0, 1024, 70, 30, {1,1,1,1}, {0.63921568627,0.2,0.78431372549,1}, {0,0,0,0}, ExitApp))

    local sc = StackCard("card_01", "Card 01", 0, 0, 1280, 720, true, {0.96862745098, 0.96862745098, 0.96862745098, 1}, {0.96484375, 0.96484375, 0.96484375, 0}, 5, sections)

    
    local text = Label("label_bundling", "The server is creating your zip, please wait...", 0, 345, 1280, 30, 30, {1,1,1,1}, "center")
    
    progressCards = {}

    local bundling = StackCard("card_bundling", "Card Bundling", 0, 0, 1280, 720, false, {0.14509803921, 0.14509803921, 0.14509803921, 1}, {0,0,0,0}, 0, {
        Card("spacer_01", "spacer_01", 0, 0, 1280, 140, {0,0,0,0}, {0,0,0,0}, {}),
        Image("downloading", "downloading", "res/packing.png", 540, 0, 1, 1),
        Label("label_bundling", "The server is creating your zip, please wait...", 0, 340, 1280, 40, 30, {1,1,1,1}, "center"),
        Label("label_done", "This might take a while.", 0, 340, 1280, 40, 20, {1,1,1,1}, "center"),
        Card("spacer_02", "spacer_02", 0, 0, 1280, 340, {0,0,0,0}, {0,0,0,0}, {})
    })

    local downloading = StackCard("card_bundling", "Card Bundling", 0, 0, 1280, 720, false, {0.14509803921, 0.14509803921, 0.14509803921, 1}, {0,0,0,0}, 0, {
        Card("spacer_01", "spacer_01", 0, 0, 1280, 140, {0,0,0,0}, {0,0,0,0}, {}),
        Image("downloading", "downloading", "res/downloading.png", 540, 0, 1, 1),
        Label("label_downloading", "Your zip is now being downloaded, please wait...", 0, 340, 1280, 40, 30, {1,1,1,1}, "center"),
        Label("label_done", "This might take a while.", 0, 340, 1280, 40, 20, {1,1,1,1}, "center"),
        Card("spacer_02", "spacer_02", 0, 0, 1280, 340, {0,0,0,0}, {0,0,0,0}, {})
    })

    local extracting = StackCard("card_bundling", "Card Bundling", 0, 0, 1280, 720, false, {0.14509803921, 0.14509803921, 0.14509803921, 1}, {0,0,0,0}, 0, {
        Card("spacer_01", "spacer_01", 0, 0, 1280, 140, {0,0,0,0}, {0,0,0,0}, {}),
        Image("downloading", "downloading", "res/extracting.png", 540, 0, 1, 1),
        Label("label_extracting", "Files are now being extracted to your SD card, please wait...", 0, 340, 1280, 40, 30, {1,1,1,1}, "center"),
        Label("label_done", "This might take a while.", 0, 340, 1280, 40, 20, {1,1,1,1}, "center"),
        Card("spacer_02", "spacer_02", 0, 0, 1280, 340, {0,0,0,0}, {0,0,0,0}, {})
    })

    local done = StackCard("card_bundling", "Card Bundling", 0, 0, 1280, 720, false, {0.14509803921, 0.14509803921, 0.14509803921, 1}, {0,0,0,0}, 0, {
        Card("spacer_01", "spacer_01", 0, 0, 1280, 280, {0,0,0,0}, {0,0,0,0}, {}),
        Label("label_done", "Done!", 0, 340, 1280, 40, 30, {1,1,1,1}, "center"),
        Label("label_done", "If you downloaded custom firmware packages, you should restart your console.", 0, 340, 1280, 40, 20, {1,1,1,1}, "center"),
        Button("button_exit", "Exit App", 128, 0, 1024, 70, 30, {1,1,1,1}, {0.85882352941,0.15686274509,0.15686274509,1}, {0,0,0,0}, ForceExitApp),
        Card("spacer_02", "spacer_02", 0, 0, 1280, 340, {0,0,0,0}, {0,0,0,0}, {})
    })

    progressCards["bundling"] = bundling
    progressCards["downloading"] = downloading
    progressCards["extracting"] = extracting
    progressCards["done"] = done

    table.insert(components, sc)
    
end

function love.load()
    uuid = Utils.UUID()

    debugtext = "LOADED"
    StateHasChanged = false


    SfxLibrary = {}
    SfxLibrary["Click"] = love.audio.newSource("res/select.wav", "stream")

    --love.system.initializeRecording()
    --love.system.enableRecording()

    cursor = love.graphics.newImage("res/cursor.png")

    defaultFont = FontFromStorage(20)
    love.graphics.setFont(defaultFont)

    packageset, code = Http.request("http://files.sdsetup.com/api/v1/get/latestpackageset")

    if code == 200 then

        local latestVersion, code = Http.request("http://files.sdsetup.com/api/v1/get/latestappversion/switch")

        if latestVersion ~= APP_VERSION then --app needs to update
            local updating = StackCard("card_bundling", "Card Bundling", 0, 0, 1280, 720, false, {0.14509803921, 0.14509803921, 0.14509803921, 1}, {0,0,0,0}, 0, {
                Card("spacer_01", "spacer_01", 0, 0, 1280, 140, {0,0,0,0}, {0,0,0,0}, {}),
                Image("downloading", "downloading", "res/downloading.png", 540, 0, 1, 1),
                Label("label_updating", "The app is updating, please wait...", 0, 340, 1280, 40, 30, {1,1,1,1}, "center"),
                Label("label_sub_updating", "The app needs to be updated to ensure compatibility.", 0, 340, 1280, 40, 20, {1,1,1,1}, "center"),
                Card("spacer_02", "spacer_02", 0, 0, 1280, 340, {0,0,0,0}, {0,0,0,0}, {})
            })
            
            table.insert(components, updating)

            drawNeedsCallback = true
            drawCallbackReady = false
            drawCallback = UpdateApp
        else --app is up to date
            GenerateComponents()

            for _,v in pairs(progressCards) do
                love.graphics.setCanvas(v.canvas)
                love.graphics.clear()
                love.graphics.setColor(1, 1, 1, 1)
                v:Draw()
                love.graphics.setCanvas()
            end
        end
    else
        local no_connection = StackCard("card_no_connection", "Card No Connection", 0, 0, 1280, 720, false, {0.14509803921, 0.14509803921, 0.14509803921, 1}, {0,0,0,0}, 0, {
            Card("spacer_01", "spacer_01", 0, 0, 1280, 320, {0,0,0,0}, {0,0,0,0}, {}),
            Label("label_done", "Could not connect to the server", 0, 340, 1280, 40, 30, {1,1,1,1}, "center"),
            Label("label_done", "Make sure your network connection is working and that www.sdsetup.com is online.", 0, 340, 1280, 40, 20, {1,1,1,1}, "center"),
            Button("button_exit", "Exit App", 128, 0, 1024, 70, 30, {1,1,1,1}, {0.85882352941,0.15686274509,0.15686274509,1}, {0,0,0,0}, ExitApp),
            Card("spacer_02", "spacer_02", 0, 0, 1280, 340, {0,0,0,0}, {0,0,0,0}, {})
        })

        table.insert(components, no_connection)
    end
    

    for i=1,table.maxn(components) do
        love.graphics.setCanvas(components[i].canvas)
        love.graphics.clear()
        love.graphics.setColor(1, 1, 1, 1)
        components[i]:Draw()
        love.graphics.setCanvas()
    end

    


end

function love.update(dt)

    for i=1,table.maxn(SubscribeUpdate) do
        if type(SubscribeUpdate[i].Update) == "function" then SubscribeUpdate[i]:Update(dt) end
    end

    for i=1,table.maxn(components) do
        if type(components[i].Update) == "function" then
            components[i]:Update()
        end
    end

    if drawNeedsCallback and drawCallbackReady and type(drawCallback) == "function" then
        drawNeedsCallback = false
        drawCallbackReady = false
        drawCallback()
    end

    

    if PrimaryJoystick ~= nil and showCursor and allowCursor then
        local leftMultiplier = 7
        local rightMultiplier = 20

        if PrimaryJoystick:isGamepadDown("zl") then 
            leftMultiplier = leftMultiplier * 0.5
            rightMultiplier = rightMultiplier * 0.5
        elseif PrimaryJoystick:isGamepadDown("zr") then
            leftMultiplier = leftMultiplier * 2
            rightMultiplier = rightMultiplier * 2
        end

        cursorX = cursorX + (axisValues["leftx"] * leftMultiplier)
        cursorY = cursorY + (axisValues["lefty"] * leftMultiplier)
        if axisValues["righty"] > 0.2 or axisValues["righty"] < 0.2 then
            love.touchmoved(9381, cursorX, cursorY, 0, -axisValues["righty"] * rightMultiplier, 1)
        end
    end

    for i=1,table.maxn(SubscribeAfterUpdate) do
        if type(SubscribeUpdate[i].AfterUpdate) == "function" then SubscribeUpdate[i]:AfterUpdate(dt) end
    end

end

function love.draw()

    for i=1,table.maxn(components) do
        love.graphics.setCanvas(components[i].canvas)
        love.graphics.clear()
        love.graphics.setColor(1, 1, 1, 1)
        if StateHasChanged then
            components[i]:CheckStates()
            components[i]:Draw()
        else
            components[i]:LiteDraw()
        end
        love.graphics.setCanvas()
    end

    StateHasChanged = false

    love.graphics.setCanvas()
    drawBackdrop()

    for i=1,table.maxn(components) do
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(components[i].canvas, components[i].x, components[i].y)
    end

    if file ~= nil then
        filelen = string.len(file)
    end

    love.graphics.setFont(FontFromStorage(20))
    love.graphics.setColor(1,0,0,1)
    --love.graphics.printf(tostring(out1) .. "\n" .. tostring(out2) .. "\n" .. tostring(out3) .. "\n" .. tostring(code) .. "\n" .. tostring(filelen).. "\n" .. tostring(drawNeedsCallback).. "\n" .. tostring(drawCallbackReady), 50, 50, 1280)

    --love.graphics.printf(love._nro_path, 50, 50, 1280)

    drawCallbackReady = true

    

    if showCursor and allowCursor then
        cursorX = cmath.clamp(cursorX, 0, 1280)
        cursorY = cmath.clamp(cursorY, 0, 720)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(cursor, cursorX, cursorY, 0, 1, 1)
    end

    love.graphics.setColor(1,1,1,1)

end

function love.touchpressed(id, x, y, dx, dy, pressure)
    showCursor = false
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    for i = 1,table.maxn(components) do
        
        if type(components[i].TouchReleased) == "function" then
            if x > components[i].x and x < (components[i].x + components[i].cx) then
                if y > components[i].y and y < (components[i].y + components[i].cy) then
                    local xSandboxed = x - components[i].x
                    local ySandboxed = y - components[i].y
                    components[i]:TouchReleased(id, xSandboxed, ySandboxed, dx, dy, pressure) 
                end
            end
        end

    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    for i=1,table.maxn(components) do
        if type(components[i].TouchMoved) == "function" then 
            if x > components[i].x and x < components[i].x + components[i].cx then
                if (y > components[i].y and y < components[i].y + components[i].cy) then
                    components[i]:TouchMoved(id, x - components[i].x, y - components[i].y, dx, dy, pressure) 
                end
            end
        end
    end
end

function love.gamepadaxis(joystick, axis, value)

    axisValues[axis] = value
    showCursor = true

end

function love.gamepadpressed(joystick, button) 
    PrimaryJoystick = joystick
end

function love.gamepadreleased(joy, button) 
    if button == "a" then --simulate touch input at cursor pos
        if showCursor and allowCursor then
            love.touchreleased(9382, cursorX, cursorY, 0, 0, 1)
        end
    end
end

function DownloadPressed()
    allowCursor = false
    love.system.blockHomeButton();
    components[1] = progressCards.bundling
    drawNeedsCallback = true
    drawCallbackReady = false
    drawCallback = GenerateZip
    
    
end

function GenerateZip()
    local chosenPackages = ""
    for k,v in pairs(GetTrueSelectedPackages()) do
        chosenPackages = chosenPackages .. k .. ";"
    end
    packageCheckboxes = nil
    out1, out2, out3 = Http.sdsetupZipRequest("http://files.sdsetup.com/api/v1/fetch/zip", uuid, packageset, "latest", chosenPackages)

    components[1] = progressCards.downloading
    progressCards.bundling = nil
    drawNeedsCallback = true
    drawCallbackReady = false
    drawCallback = DownloadZip
end

function DownloadZip()
    if out2 == "READY" then
        local file, code = Http.request("http://files.sdsetup.com/api/v1/fetch/generatedzip/" .. uuid)
        love.filesystem.write("sdmc:/sdsetup.zip", file)
        file = nil
    end

    components[1] = progressCards.extracting
    progressCards.downloading = nil
    drawNeedsCallback = true
    drawCallbackReady = false
    drawCallback = ExtractZip
end

function ExtractZip()
    love.filesystem.unzip("/sdsetup.zip", "/")
end

function drawBackdrop()
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle('fill', 0, 0, 1280, 720)
end

function unzipUpdate(currentValue, maxValue)
    zipMax = maxValue
    zipProgress = currentValue
end

function unzipDone()
    love.filesystem.remove("sdmc:/sdsetup.zip")
    allowCursor = true
    love.system.unblockHomeButton();
    components[1] = progressCards.done
    progressCards.extracting = nil
    --StateHasChanged = true
end

function GetSelectedPackages()
    debugtext = ""
    for i=1,table.maxn(packageCheckboxes) do
        if packageCheckboxes[i].enabled then debugtext = debugtext .. packageCheckboxes[i].tag.ID .. "\n" end
    end
end

function GetTrueSelectedPackages()
    
    local gottenPackages = {}
    debugtext = ""
    debugtext = 0
    for i=1,table.maxn(packageCheckboxes) do
        if packageCheckboxes[i].enabled then RecursivelyFindDependencies(gottenPackages, packageCheckboxes[i].tag) end
    end
    
    return gottenPackages
end

function RecursivelyFindDependencies(gottenPackages, p)

    if p == "" then return end
    
    if gottenPackages[p.ID] == nil then
        
        gottenPackages[p.ID] = p
    end
    
    for _,v in pairs(p.Dependencies) do 
        debugtext = debugtext + 1
        RecursivelyFindDependencies(gottenPackages, FindPackage(v)) 
    end
end

function FindPackage(id)
    
    for _,v in pairs(packageItems) do
        if v.ID == id then 
            
            return v
        end
    end

    return ""
end

function FontFromStorage(size)
    if fontStore == nil then fontStore = {} end
    if fontStore[size] == nil then fontStore[size] = love.graphics.newFont(size) end
    return fontStore[size]
end

function ExitApp()
    love.event.quit()
end

function ForceExitApp()
    love.system.requestHomeMenu()

    --above doesnt work with games, so exit normally (oh well)
    love.event.quit()
end

function UpdateApp()
    if PrimaryJoystick ~= nil then
        if PrimaryJoystick:isGamepadDown("r") then --skip update by holding R on boot
            table.remove(components, 1)

            GenerateComponents()

            for _,v in pairs(progressCards) do
                love.graphics.setCanvas(v.canvas)
                love.graphics.clear()
                love.graphics.setColor(1, 1, 1, 1)
                v:Draw()
                love.graphics.setCanvas()
            end
            return
        end
    end

    love.filesystem.romfsExit()

    love.filesystem.remove(love._nro_path)

    local file, code = Http.request("http://files.sdsetup.com/api/v1/get/latestappdownload/switch/")
    love.filesystem.write(love._nro_path, file)
    file = nil

    love.filesystem.setNextLoad(love._nro_path)

    love.event.quit()
end