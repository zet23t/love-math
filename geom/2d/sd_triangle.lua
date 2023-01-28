local clamp = require "love-math.clamp"
local dot = require "love-math.geom.2d.dot"

return function(px, py, p0x, p0y, p1x, p1y, p2x, p2y)
	--  signed distance to a 2D triangle
	--  from https://www.shadertoy.com/view/XsXSz4

	local e0x, e0y = p1x - p0x, p1y - p0y
	local e1x, e1y = p2x - p1x, p2y - p1y
	local e2x, e2y = p0x - p2x, p0y - p2y

	local v0x, v0y = px - p0x, py - p0y
	local v1x, v1y = px - p1x, py - p1y
	local v2x, v2y = px - p2x, py - p2y

	local c0 = clamp(0.0, 1.0, dot(v0x, v0y, e0x, e0y) / dot(e0x, e0y, e0x, e0y))
	local c1 = clamp(0.0, 1.0, dot(v1x, v1y, e1x, e1y) / dot(e1x, e1y, e1x, e1y))
	local c2 = clamp(0.0, 1.0, dot(v2x, v2y, e2x, e2y) / dot(e2x, e2y, e2x, e2y))

	local pq0x, pq0y = v0x - e0x * c0, v0y - e0y * c0
	local pq1x, pq1y = v1x - e1x * c1, v1y - e1y * c1
	local pq2x, pq2y = v2x - e2x * c2, v2y - e2y * c2

	local s = e0x * e2y - e0y * e2x;

	local dx = math.min(
		dot(pq0x, pq0y, pq0x, pq0y),
		dot(pq1x, pq1y, pq1x, pq1y),
		dot(pq2x, pq2y, pq2x, pq2y))
	local dy = math.min(
		s * (v0x * e0y - v0y * e0x),
		s * (v1x * e1y - v1y * e1x),
		s * (v2x * e2y - v2y * e2x))

	return -(dx ^ .5) * (dy < 0 and -1 or 1);
end