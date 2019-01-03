require 'class'
cmath = require("cmath")



Image = class(
    function(obj, id, name, imagePath, x, y, sx, sy)
        obj.id = id
        obj.name = name
        obj.imagePath = imagePath
        obj.image = love.graphics.newImage(imagePath)
        obj.x = x -- origin x
        obj.y = y -- origin y
        obj.sx = sx -- scale x
        obj.sy = sy -- scale y
        obj.dx = obj.image:getWidth()
        obj.dy = obj.image:getHeight()
        obj.StateHasChanged = true
        obj.canvas = love.graphics.newCanvas(obj.image:getWidth(), obj.image:getHeight())
    end
)

function Image:CheckStates()
    return self.StateHasChanged 
end

function Image:ResetCanvas()
    self.canvas = love.graphics.newCanvas(self.image:getWidth(), self.image:getHeight())
end

function Image:ReloadImage()
    self.image = love.graphics.newImage(self.imagePath)
end

function Image:Draw()
    love.graphics.draw(self.image, 0, 0, 0, self.sx, self.sy)

    self.StateHasChanged = false
end

function Image:__tostring()
    return "< OBJECT [TYPE: IMAGE] [NAME: " .. self.name .. "] >"
end
