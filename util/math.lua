
function math.clamp(n, min, max)
	return math.min(math.max(n, min), max)
end

function pointInRect(x, y, rx, ry, w, h)
	return x >= rx and x <= rx + w and y >= ry and y <= ry + h
end

function pointInCircle(x, y, cx, cy, r)
    local dx = x - cx
    local dy = y - cy
    return dx * dx + dy * dy <= r * r
end
