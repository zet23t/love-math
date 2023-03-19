local cross = require "love-math.geom.3d.cross"
local dot3d = require "love-math.geom.3d.dot3d"
local function calc_closest_points_of_two_lines(a1x, a1y, a1z, a2x, a2y, a2z, b1x, b1y, b1z, b2x, b2y, b2z)
	local adx, ady, adz = a2x - a1x, a2y - a1y, a2z - a1z
	local bdx, bdy, bdz = b2x - b1x, b2y - b1y, b2z - b1z
	local nx, ny, nz = cross(adx, ady, adz, bdx, bdy, bdz)
	if nx == 0 and ny == 0 and nz == 0 then
		return
	end
	local anx, any, anz = cross(adx, ady, adz, nx, ny, nz)
	local bnx, bny, bnz = cross(bdx, bdy, bdz, nx, ny, nz)
	local ndot = dot3d(nx, ny, nz, nx, ny, nz)
	local ddx, ddy, ddz = b1x - a1x, b1y - a1y, b1z - a1z
	
	local at = dot3d(bnx, bny, bnz, ddx, ddy, ddz) / ndot
	local bt = dot3d(anx, any, anz, ddx, ddy, ddz) / ndot
	local ax, ay, az = a1x + adx * at, a1y + ady * at, a1z + adz * at
	local bx, by, bz = b1x + bdx * bt, b1y + bdy * bt, b1z + bdz * bt
	
	return ax, ay, az, bx, by, bz
end

return calc_closest_points_of_two_lines
