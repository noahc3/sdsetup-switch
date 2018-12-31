require 'class'
cmath = require("cmath")



Checkbox = class(
    function(obj, id, text, x, y, dx, dy, fontSize, checkboxSize, checkboxPadding, fontColor, checkboxColor, checkboxBorderColor, enabled, tag)
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
        obj.checkboxSize = checkboxSize
        obj.checkboxPadding = checkboxPadding
        obj.fontColor = fontColor
        obj.checkboxColor = checkboxColor
        obj.checkboxBorderColor = checkboxBorderColor
        obj.StateHasChanged = true
        obj.tag = tag

        love.graphics.setFont(love.graphics.newFont(obj.fontSize))

        obj.dx = love.graphics.getFont():getWidth(obj.text) + checkboxSize + checkboxPadding

        obj.canvas = love.graphics.newCanvas(obj.dx, obj.dy)
    end
)

function Checkbox:ResetCanvas()
    self.canvas = love.graphics.newCanvas(self.dx, self.dy)
end

function Checkbox:CheckStates()
    return self.StateHasChanged 
end

function Checkbox:Draw()
    love.graphics.setColor(unpack(self.checkboxColor))
    love.graphics.rectangle("fill", 0, 0, self.checkboxSize, self.checkboxSize)

    love.graphics.setColor(unpack(self.checkboxBorderColor))
    love.graphics.rectangle("line", 0, 0, self.checkboxSize, self.checkboxSize)
    love.graphics.rectangle("line", 1, 1, self.checkboxSize - 2, self.checkboxSize - 2)

    if self.enabled then
        love.graphics.rectangle("fill", 4, 4, self.checkboxSize - 9, self.checkboxSize - 9)
    end

    love.graphics.setColor(unpack(self.fontColor))
    love.graphics.setFont(love.graphics.newFont(self.fontSize))
    love.graphics.printf( self.text, self.checkboxSize + self.checkboxPadding, 0, self.dx, "left" )
    
    self.StateHasChanged = false
end

function Checkbox:TouchReleased(id, x, y, dx, dy, pressure)
    if self.enabled then self.enabled = false
    else self.enabled = true
    end

    SfxLibrary["Click"]:play()

    StateHasChanged = true
    self.StateHasChanged = true
    --touched = self.id
end

function Checkbox:__tostring()
    return "< OBJECT [TYPE: LABEL] [TEXT: " .. self.text .. "] >"
end
