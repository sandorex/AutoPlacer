local M = {}

-- calculate distance between two points
function M.distance_between(p1, p2)
    local x1 = p1.x
    local x2 = p2.x
    local y1 = p1.y
    local y2 = p2.y

    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

return M
