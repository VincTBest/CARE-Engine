
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

-- Colliders

COLLIDERS = {
	l = {}
}

COLLIDER_CHECK_POINTS = {}

function COLLIDER_CHECK_POINTS.square(this, that)
	return pointInRect(that.x, that.y, this.x, this.y, this.w, this.h)
end

function COLLIDER_CHECK_POINTS.circle(this, that)
	return pointInCircle(that.x, that.y, this.x, this.y, this.r)
end

function createColliderLayer()
	table.insert(COLLIDERS.l, {c=rCol("1110"), i={}})
	return #COLLIDERS.l
end

function createCollider(layer, shape, x, y, p1, p2, p3, p4)
	if layer > #COLLIDERS.l then error("Specified layer does not exist!") end

	local collider = {shape=shape, x=x, y=y, c=rCol("1110")}
	if shape == "square" then
		collider.w = p1
		collider.h = p2
	elseif shape == "circle" then
		collider.r = p1
	else
		error("Collision shape does not exist!")
	end
	collider.checkPoint = COLLIDER_CHECK_POINTS[shape]
	table.insert(COLLIDERS.l[layer].i, collider)
end

function visualizeColliders()
	for l=1,#COLLIDERS.l do
		local layer = COLLIDERS.l[l]
		for cl=1,#layer.i do
			local coll = layer.i[cl]
			setColor(coll.c)
			if coll.shape == "square" then
				rect("fill", coll.x, coll.y, coll.w, coll.h)
			elseif coll.shape == "circle" then
				circleFill(coll.x, coll.y, coll.r)
			end
		end
	end
end
