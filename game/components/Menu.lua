require 'class'
cmath = require("cmath")



Menu = class(
    function(obj, id, items, x, y, cx, buttonHeight, fontSize)
        obj.id = id
        obj.x = x -- origin x
        obj.y = y -- origin y
        obj.cx = cx -- width
        obj.buttonHeight = buttonHeight -- height
        obj.fontSize = fontSize
        obj.canvas = love.graphics.newCanvas(dx, dy)
    end
)

function Label:ResetCanvas()
    self.canvas = love.graphics.newCanvas(self.dx, self.dy)
end

function Label:Draw()
    love.graphics.setFont(self.fontSize)
    love.graphics.printf( self.text, 0, 0, self.dx, "left" )
end

function Label:__tostring()
    return "< OBJECT [TYPE: LABEL] [TEXT: " .. self.text .. "] >"
end
