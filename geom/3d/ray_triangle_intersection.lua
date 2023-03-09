local sub    = require "love-math.geom.3d.sub3d3d"
local cross  = require "love-math.geom.3d.cross"
local mat4x4 = require "love-math.affine.mat4x4"
local dot    = require "love-math.geom.3d.dot3d"

local m_tmp = mat4x4:new()

---Möller–Trumbore intersection algorithm
---@param backface_cull boolean if true, only front facing triangles are considered
---@param ray_x number
---@param ray_y number
---@param ray_z number
---@param dir_x number
---@param dir_y number
---@param dir_z number
---@param ax number triangle corner a
---@param ay number
---@param az number
---@param bx number triangle corner b
---@param by number
---@param bz number
---@param cx number triangle corner c
---@param cy number
---@param cz number
---@return number|nil hit_x
---@return number|nil hit_y
---@return number|nil hit_z
---@return number|nil normal_x
---@return number|nil normal_y
---@return number|nil normal_z
return function(backface_cull, ray_x, ray_y, ray_z, dir_x, dir_y, dir_z, ax, ay, az, bx, by, bz, cx, cy, cz)
	bx, by, bz       = sub(bx, by, bz, ax, ay, az)
	cx, cy, cz       = sub(cx, cy, cz, ax, ay, az)
	local hx, hy, hz = cross(dir_x, dir_y, dir_z, cx, cy, cz)
	local a          = dot(hx, hy, hz, bx, by, bz)

	if backface_cull and a > 0 then
		return
	end

	if math.abs(a) <= 0.0000001 then
		return
	end

	local f = 1 / a
	local sx, sy, sz = sub(ray_x, ray_y, ray_z, ax, ay, az)
	local u = dot(sx, sy, sz, hx, hy, hz) * f
	if u < 0 or u > 1 then
		return
	end

	local qx, qy, qz = cross(sx, sy, sz, bx, by, bz)
	local v = dot(dir_x, dir_y, dir_z, qx, qy, qz) * f

	if v < 0 or u + v > 1 then
		return
	end

	local t = dot(qx, qy, qz, cx, cy, cz) * f

	if t >= 0.0000001 then
		local nx, ny, nz = cross(cx, cy, cz, bx, by, bz)
		return ray_x + dir_x * t, ray_y + dir_y * t, ray_z + dir_z * t, nx, ny, nz
	end
end
