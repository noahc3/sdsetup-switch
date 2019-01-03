local Factory = {}

function Factory.newAnimation(frameRoot, frameCount, frameDuration)

    local animation = {}

    animation.frame = 1
    animation.frames = {}
    animation.frameCount = frameCount
    animation.frameDuration = frameDuration
    animation.__frameCounter = 0

    for i=1,frameCount do
        table.insert(animation.frames, love.graphics.newImage(frameRoot .. i .. ".png"))
    end
    
    function animation.cycleFrame(self, dt) 
        self.__frameCounter = self.__frameCounter + dt
        if self.__frameCounter > self.frameDuration then
            self.__frameCounter = 0
            self.frame = self.frame + 1
        end

        if self.frame > self.frameCount then
            self.frame = 1
        end
    end

    function animation.getFrame(self) 
        return self.frames[self.frame]
    end
 
    return animation
end

return Factory