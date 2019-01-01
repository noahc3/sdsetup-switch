require 'class'
cmath = require("cmath")



Label = class(
    function(obj, id, text, x, y, dx, dy, fontSize, color, positioning)
        obj.id = id
        obj.text = text
        obj.x = x -- origin x
        obj.y = y -- origin y
        obj.dx = dx -- width
        obj.dy = dy -- height
        obj.positioning = positioning
        obj.fontSize = fontSize
        obj.color = color
        obj.StateHasChanged = true

        love.graphics.setFont(FontFromStorage(obj.fontSize))


        if obj.positioning == "center" then
            obj.x = obj.x + (obj.dx / 2) - (love.graphics.getFont():getWidth(obj.text) / 2)
        end

        obj.dx = love.graphics.getFont():getWidth(obj.text)

        obj.canvas = love.graphics.newCanvas(obj.dx, obj.dy)

    end
)

function Label:CheckStates()
    return self.StateHasChanged 
end

function Label:ResetCanvas()
    self.canvas = love.graphics.newCanvas(self.dx, self.dy)
end

function Label:Draw()
    love.graphics.setColor(unpack(self.color))
    love.graphics.setFont(FontFromStorage(self.fontSize))

    love.graphics.printf( self.text, 0, 0, self.dx, "left" )

    self.StateHasChanged = false
    
end

function Label:__tostring()
    return "< OBJECT [TYPE: LABEL] [TEXT: " .. self.text .. "] >"
end
