require 'class'
cmath = require("cmath")
Factory = require("Factory")



Animation = class(
    function(obj, id, animationPath, x, y, cellWidth, cellHeight, duration)
        obj.id = id
        obj.name = name
        obj.x = x -- origin x
        obj.y = y -- origin y
        obj.dx = cellWidth
        obj.dy = cellHeight
        obj.duration = duration
        obj.animationPath = animationPath
        obj.animation = Factory.newAnimation(love.graphics.newImage(obj.animationPath), obj.dx, obj.dy, obj.duration)
        obj.StateHasChanged = true
        obj.canvas = love.graphics.newCanvas(obj.dx, obj.dy)

        table.insert(SubscribeUpdate, obj)
    end
)

function Animation:CheckStates()
    return self.StateHasChanged 
end

function Animation:ResetCanvas()
    self.canvas = love.graphics.newCanvas(self.image:getWidth(), self.image:getHeight())
end

function Animation:ReloadImage()
    self.image = love.graphics.newImage(self.imagePath)
end

function Animation:Update(dt)
    local anim = self.animation

    anim.currentTime = anim.currentTime + dt
    if anim.currentTime >= anim.duration then
        anim.currentTime = anim.currentTime - anim.duration
    end

    StateHasChanged = true
    self.StateHasChanged = true
end

function Animation:Draw()
    local anim = self.animation

    local spriteNum = math.floor(anim.currentTime / anim.duration * #anim.quads) + 1
    love.graphics.draw(anim.spriteSheet, anim.quads[spriteNum], 0, 0) 
end

function Animation:__tostring()
    return "< OBJECT [TYPE: IMAGE] [NAME: " .. self.name .. "] >"
end
