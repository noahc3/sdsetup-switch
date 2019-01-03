require 'class' 

require 'types/t_Animation'



Animation = class(
    function(obj, id, x, y, dx, dy, animationRoot, frameCount, frameDuration)
        obj.id = id
        obj.name = name
        obj.x = x -- origin x
        obj.y = y -- origin y
        obj.dx = dx
        obj.dy = dy
        obj.animation = t_Animation(animationRoot, frameCount, frameDuration)
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
    self.animation:cycleFrame(dt)

    StateHasChanged = true
    self.StateHasChanged = true
end

function Animation:Draw()
    love.graphics.draw(self.animation.frames[self.animation.frame], 0, 0) 
end

function Animation:__tostring()
    return "< OBJECT [TYPE: IMAGE] [NAME: " .. self.name .. "] >"
end
