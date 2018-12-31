local Math = {}

function Math.clamp(value, min, max)
    if (value > max) then return max
    elseif (value < min) then return min
    else return value end
end

return Math