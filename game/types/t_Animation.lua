require 'class'

t_Animation = class(
    function(obj, frameRoot, frameCount, frameDuration)
        obj.frame = 1
        obj.frames = {}
        obj.frameRoot = frameRoot
        obj.frameCount = frameCount
        obj.frameDuration = frameDuration
        obj.__frameCounter = 0

        for i=1,obj.frameCount do
            table.insert(obj.frames, love.graphics.newImage(obj.frameRoot .. i .. ".png"))
        end
    end
)

function t_Animation:cycleFrame(dt) 
    self.__frameCounter = self.__frameCounter + dt
    if self.__frameCounter > self.frameDuration then
        self.__frameCounter = 0
        self.frame = self.frame + 1
    end

    if self.frame > self.frameCount then
        self.frame = 1
    end
end