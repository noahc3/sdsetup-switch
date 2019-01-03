require 'class'
cmath = require("cmath")

--card that automatically expands in the y direction based on children and automatically stacks them, ignoring y positions.
--passed in components should be a numerically indexed table or an ordered table to maintain drawing order.

StackCard = class(
    function(obj, id, title, x, y, dx, cy, canScroll, backgroundColor, borderColor, childPadding, components)
        obj.id = id
        obj.title = title
        obj.x = x -- origin x
        obj.y = y -- origin y
        obj.dx = dx -- true x (width)
        obj.dy = 0 -- still instantiate dy, it will be set internally
        obj.cx = dx
        obj.cy = cy
        obj.vy = cy
        obj.canScroll = canScroll
        obj.backgroundColor = backgroundColor
        obj.borderColor = borderColor
        obj.components = components
        obj.childPadding = childPadding
        obj.drawDelay = 30
        obj.drawDelayMax = obj.drawDelay
        obj.StateHasChanged = true

        --TODO move this stuff to love.update() for performance
        local maxy = 0

        --calculate maximum y position being rendered and set the height to that
        --since component rendering is always trimmed outside of canvas no funky business will happen (ex. rendering out of bounds) so this is safe
            --that said, nothing can ever render out of bounds in a stack element as their x and y values are not respected.
        for i=1,table.maxn(obj.components) do
            if obj.components[i].dy == nil then
                local alsomaxy = 0
                for n=1,table.maxn(obj.components[i]) do
                    if obj.components[i][n].dy > alsomaxy then alsomaxy = obj.components[i][n].dy end
                end
                maxy = maxy + alsomaxy + childPadding
            else
                maxy = maxy + obj.components[i].dy + childPadding
            end
            
        end

        if obj.dy == 0 then obj.dy = maxy end
        obj.canvas = love.graphics.newCanvas(obj.dx, obj.dy)
        obj.cy = obj.dy

        
        obj.scrollPosX = 0
        obj.scrollPosY = 0
        obj.scrollMomentum = 0

        
    end
)

function StackCard:Update()
    self.scrollPosY = self.scrollPosY + self.scrollMomentum
    if (self.scrollMomentum > 0) then
        self.scrollMomentum = cmath.clamp(self.scrollMomentum - 3, 0, self.scrollMomentum)
    else
        self.scrollMomentum = cmath.clamp(self.scrollMomentum + 3, self.scrollMomentum, 0)
    end
end

function StackCard:ResetCanvas()
    local maxy = 0
    for i=1,table.maxn(self.components) do
        if self.components[i].dy == nil then
            local alsomaxy = 0
            for n=1,table.maxn(self.components[i]) do
                if self.components[i][n].dy > alsomaxy then alsomaxy = self.components[i][n].dy end
            end
            maxy = maxy + alsomaxy + self.childPadding
        else
            maxy = maxy + self.components[i].dy + self.childPadding
        end
        
    end

    if self.dy == 0 then self.dy = maxy end
    self.canvas = love.graphics.newCanvas(self.dx, self.dy)
end

function StackCard:LiteDraw()
    love.graphics.setCanvas(self.canvas)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle('fill', 0, 0, self.dx, self.dy)

    love.graphics.setColor(unpack(self.borderColor))
    love.graphics.rectangle('line', 0, 0, self.dx, self.dy)

    if (self.canScroll) then
        self.scrollPosY = cmath.clamp(self.scrollPosY, -self.dy + self.vy, 0)
    end

    love.graphics.setColor(0,0,0,1)

    if self.canScroll then
        love.graphics.translate(self.scrollPosX, self.scrollPosY)
    end


    --stack card will ignore specified Y values on child component and render linearly.
    --because of this, anything that should be in rows or be offset horizontally should use another card component to group it.
    love.graphics.setColor(1, 1, 1, 1)

    local currenty = 0

    for i=1,table.maxn(self.components) do
        if self.components[i].dy == nil then
            local alsomaxy = 0
            for n=1,table.maxn(self.components[i]) do
                if self.components[i][n].dy > alsomaxy then alsomaxy = self.components[i][n].dy end
                love.graphics.draw(self.components[i][n].canvas, self.components[i][n].x, currenty)
                self.components[i][n].y = currenty
            end
            currenty = currenty + alsomaxy + self.childPadding
        else
            love.graphics.draw(self.components[i].canvas, self.components[i].x, currenty)
            self.components[i].y = currenty
            currenty = currenty + self.components[i].dy + self.childPadding
        end
    end

    if self.canScroll then
        love.graphics.translate(-self.scrollPosX, -self.scrollPosY)
    end

    love.graphics.setColor(0,0,0,1)
    
end

function StackCard:CheckStates() 
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

function StackCard:Draw()
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

    if (self.canScroll) then
        self.scrollPosY = cmath.clamp(self.scrollPosY, -self.dy + self.vy, 0)
    end

    love.graphics.setColor(0,0,0,1)

    if self.canScroll then
        love.graphics.translate(self.scrollPosX, self.scrollPosY)
    end


    --stack card will ignore specified Y values on child component and render linearly.
    --because of this, anything that should be in rows or be offset horizontally should use another card component to group it.
    love.graphics.setColor(1, 1, 1, 1)

    local currenty = 0

    for i=1,table.maxn(self.components) do
        if self.components[i].dy == nil then
            local alsomaxy = 0
            for n=1,table.maxn(self.components[i]) do
                if self.components[i][n].dy > alsomaxy then alsomaxy = self.components[i][n].dy end
                love.graphics.draw(self.components[i][n].canvas, self.components[i][n].x, currenty)
                self.components[i][n].y = currenty
            end
            currenty = currenty + alsomaxy + self.childPadding
        else
            love.graphics.draw(self.components[i].canvas, self.components[i].x, currenty)
            self.components[i].y = currenty
            currenty = currenty + self.components[i].dy + self.childPadding
        end
    end
    if self.canScroll then
        love.graphics.translate(-self.scrollPosX, -self.scrollPosY)
    end

    self.StateHasChanged = false
    
end

function StackCard:TouchMoved(id, x, y, dx, dy, pressure)
    --touched = true
    if (math.abs(self.scrollMomentum) > math.abs(dy)) then
        delta = math.abs(dy)
    else
        delta = 0.3 * math.abs(dy)
    end

    if (self.scrollMomentum > dy) then
        self.scrollMomentum = cmath.clamp(self.scrollMomentum - delta, dy, self.scrollMomentum)
    else
        self.scrollMomentum = cmath.clamp(self.scrollMomentum + delta, self.scrollMomentum, dy)
    end
end

function StackCard:TouchReleased(id, x, y, dx, dy, pressure)
    local comps = {}
    local y = y - self.scrollPosY
    touched = self.id

    for i=1,table.maxn(self.components) do
        if self.components[i].dy == nil then
            for n=1,table.maxn(self.components[i]) do
                table.insert(comps, self.components[i][n])
            end
        else
            table.insert(comps, self.components[i])
        end
    end

    for i = 1,table.maxn(comps) do
        
        if type(comps[i].TouchReleased) == "function" then
            if x > comps[i].x and x < (comps[i].x + comps[i].cx) then
                if y > comps[i].y and y < (comps[i].y + comps[i].cy) then
                    local xSandboxed = x - comps[i].x
                    local ySandboxed = y - comps[i].y
                    comps[i]:TouchReleased(id, xSandboxed, ySandboxed, dx, dy, pressure) 
                end
            end
        end

    end
end

function StackCard:__tostring()
    return "< OBJECT [TYPE: PAGE] [NAME: " .. self.name .. "] >"
end

