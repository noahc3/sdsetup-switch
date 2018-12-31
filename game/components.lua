local components = {}

function components.progressBar(x, y, progress, max)
    ocR, ocG, ocB, ocA = love.graphics.getColor();

    love.graphics.setColor(0.453125, 0.453125, 0.453125)
    love.graphics.rectangle("fill", x, y, 400, 12, 4, 4)

    love.graphics.setColor(0, 0.98828125, 0.78515625)
    love.graphics.rectangle("fill", x, y, 400 * (progress / max), 12, 4, 4)

    love.graphics.setColor(1,1,1)
    love.graphics.printf( math.floor((progress * 100) / max) .. "%", x + 415, y - 4, 960, "left" )

    love.graphics.setColor(ocR, ocG, ocB, ocA)
end

function components.printc(text, x, y, width)
    love.graphics.printf( text, x - (love.graphics.getFont():getWidth(text) / 2), y, width, "left")
end

return components