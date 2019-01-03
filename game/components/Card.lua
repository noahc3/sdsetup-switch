require 'class'
cmath = require("cmath")



Card = class(
    function(obj, id, title, x, y, dx, dy, backgroundColor, borderColor, components)
        obj.id = id
        obj.title = title
        obj.x = x -- origin x
        obj.y = y -- origin y
        obj.dx = dx -- true x (width)
        obj.dy = dy -- true y (height)
        obj.cx = dx
        obj.cy = dy
        obj.backgroundColor = backgroundColor
        obj.borderColor = borderColor
        obj.components = components
        obj.canvas = love.graphics.newCanvas(obj.dx, obj.dy)
        obj.StateHasChanged = true
    end
)

function Card:ResetCanvas()
    self.canvas = love.graphics.newCanvas(self.dx, self.dy)
end

function Card:CheckStates() 
    local redraw = false
    for i=1,table.maxn(self.components) do
        if self.components[i].dy == nil then
            for n=1,table.maxn(self.components[i]) do
                if self.components[i][n]:CheckStates() then redraw = true end
            end
        else
            if self.components[i]:CheckStates() then redraw = true end
        end
    end

    self.StateHasChanged = redraw
    return redraw
end

function Card:Draw()
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
    love.graphics.rectangle('fill', 0, 0, self.dx, self.dy)

    love.graphics.setColor(unpack(self.borderColor))
    love.graphics.rectangle('line', 0, 0, self.dx, self.dy)

    for i=1,table.maxn(self.components) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.components[i].canvas, self.components[i].x, self.components[i].y)
    end
end

function Card:LiteDraw()
    
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle('fill', 0, 0, self.dx, self.dy)

    love.graphics.setColor(unpack(self.borderColor))
    love.graphics.rectangle('line', 0, 0, self.dx, self.dy)

    love.graphics.setColor(1, 1, 1, 1)


    for i=1,table.maxn(self.components) do
        if self.components[i].dy == nil then
            for n=1,table.maxn(self.components[i]) do
                love.graphics.draw(self.components[i][n].canvas, self.components[i][n].x, self.component[i][n].y)
            end
        else
            love.graphics.draw(self.components[i].canvas, self.components[i].x, self.component[i].y)
        end
    end

    love.graphics.setColor(1,1,1,1)
end

function Card:Draw()
    for i=1,table.maxn(self.components) do
        if self.components[i].dy == nil then
            for n=1,table.maxn(self.components[i]) do
                if self.components[i][n].StateHasChanged then
                    love.graphics.setCanvas(self.components[i][n].canvas)
                    love.graphics.clear()
                    love.graphics.setColor(1, 1, 1, 1)
                    self.components[i][n]:Draw()
                end
            end
        else
            if self.components[i].StateHasChanged then
                love.graphics.setCanvas(self.components[i].canvas)
                love.graphics.clear()
                love.graphics.setColor(1, 1, 1, 1)
                self.components[i]:Draw()
            end
        end
    end
    love.graphics.setCanvas(self.canvas)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle('fill', 0, 0, self.dx, self.dy)

    love.graphics.setColor(unpack(self.borderColor))
    love.graphics.rectangle('line', 0, 0, self.dx, self.dy)

    love.graphics.setColor(0,0,0,1)


    --stack card will ignore specified Y values on child component and render linearly.
    --because of this, anything that should be in rows or be offset horizontally should use another card component to group it.
    love.graphics.setColor(1, 1, 1, 1)

    for i=1,table.maxn(self.components) do
        if self.components[i].dy == nil then
            for n=1,table.maxn(self.components[i]) do
                love.graphics.draw(self.components[i][n].canvas, self.components[i][n].x, self.components[i][n].y)
            end
        else
            love.graphics.draw(self.components[i].canvas, self.components[i].x, self.components[i].y)
        end
    end

    self.StateHasChanged = false
    
end

function Card:__tostring()
    return "< OBJECT [TYPE: PAGE] [NAME: " .. self.name .. "] >"
end