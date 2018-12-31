require 'class'
cmath = require("cmath")



Button = class(
    function(obj, id, text, x, y, dx, dy, fontSize, fontColor, buttonColor, buttonBorderColor, clickCallback)
        obj.id = id
        obj.text = text
        obj.x = x -- origin x
        obj.y = y -- origin y
        obj.dx = dx -- width
        obj.dy = dy -- height
        obj.cx = dx -- for touch compat
        obj.cy = dy -- for touch compat
        obj.enabled = enabled
        obj.fontSize = fontSize
        obj.fontColor = fontColor
        obj.buttonColor = buttonColor
        obj.buttonBorderColor = buttonBorderColor
        obj.StateHasChanged = true
        obj.clickCallback = clickCallback

        obj.canvas = love.graphics.newCanvas(obj.dx, obj.dy)
    end
)

function Button:ResetCanvas()
    self.canvas = love.graphics.newCanvas(self.dx, self.dy)
end

function Button:CheckStates()
    return self.StateHasChanged 
end

function Button:Draw()
    love.graphics.setColor(unpack(self.buttonColor))
    love.graphics.rectangle("fill", 0, 0, self.dx, self.dy)

    love.graphics.setColor(unpack(self.buttonBorderColor))
    love.graphics.rectangle("line", 0, 0, self.dx, self.dy)
    love.graphics.rectangle("line", 1, 1, self.dx - 2, self.dy - 2)

    love.graphics.setColor(unpack(self.fontColor))
    love.graphics.setFont(love.graphics.newFont(self.fontSize))

    local xpos = (self.dx / 2) - (love.graphics.getFont():getWidth(self.text) / 2)
    local ypos = (self.dy / 2) - (self.fontSize / 2)

    love.graphics.printf( self.text, xpos, ypos, self.dx, "left" )
    
    self.StateHasChanged = false
end

function Button:TouchReleased(id, x, y, dx, dy, pressure)
    SfxLibrary["Click"]:play()
    if type(self.clickCallback) == "function" then
        self.clickCallback()
    end
end

function Button:__tostring()
    return "< OBJECT [TYPE: LABEL] [TEXT: " .. self.text .. "] >"
end
