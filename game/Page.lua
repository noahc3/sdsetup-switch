require 'class'
cmath = require("cmath")



Page = class(
    function(obj, id, name, x, y, cx, cy, dx, dy, canScroll, backgroundColor, components)
        obj.id = id
        obj.name = name
        obj.x = x -- origin x
        obj.y = y -- origin y
        obj.cx = cx -- canvas x (width)
        obj.cy = cy -- canvas y (height)
        obj.dx = dx -- true x (width)
        obj.dy = dy -- true y (height)
        obj.canScroll = canScroll
        obj.backgroundColor = backgroundColor
        obj.components = components
        obj.scrollPosX = 0
        obj.scrollPosY = 0
        obj.canvas = love.graphics.newCanvas(obj.cx, obj.cy)
    end
)

function Page:ResetCanvas()
    self.canvas = love.graphics.newCanvas(self.cx, self.cy)
end

function Page:Draw()
    for i=1,table.maxn(self.components) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setCanvas(self.components[i].canvas)
        love.graphics.clear()
        love.graphics.setColor(1, 1, 1, 1)
        self.components[i]:Draw()
        love.graphics.setCanvas(self.canvas)
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle('fill', 0, 0, self.cx, self.cy)

    self.scrollPosX = cmath.clamp(self.scrollPosX, -self.dx + self.cx, 0)
    self.scrollPosY = cmath.clamp(self.scrollPosY, -self.dy + self.cy, 0)

    love.graphics.translate(self.scrollPosX, self.scrollPosY)

    for i=1,table.maxn(self.components) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.components[i].canvas, self.components[i].x, self.components[i].y)
    end

    love.graphics.translate(-self.scrollPosX, -self.scrollPosY)

    love.graphics.setColor(0,0,0,1)
    love.graphics.printf(self.scrollPosY, 50, 50, 500)
end

function Page:TouchMoved(id, x, y, dx, dy, pressure)
    self.scrollPosY = self.scrollPosY + dy
end

function Page:__tostring()
    return "< OBJECT [TYPE: PAGE] [NAME: " .. self.name .. "] >"
end