local lerp         = require "love-math.geom.3d.lerp3d"
local clamp        = require "love-math.clamp"
local vector_angle = require "love-math.geom.3d.vector_angle"
local normalize3d  = require "love-math.geom.3d.normalize3d"
local format_nums  = require "love-util.format_nums"
local distance_squared = require "love-math.geom.3d.distance_squared"

---@class spline : object a bezier spline with some useful additional functions
---@field points table[]
local spline       = require "love-util.class" "spline"

function spline:new()
	return self:create {
		points = {}
	}
end

---adds a new point to the end of the list of points
---@param x number position
---@param y number position
---@param z number position
---@param in_tx number|nil incoming tangent, defaults to 0
---@param in_ty number|nil incoming tangent, defaults to 0
---@param in_tz number|nil incoming tangent, defaults to 0
---@param out_tx number|nil outgoing tangent, default to 0
---@param out_ty number|nil outgoing tangent, default to 0
---@param out_tz number|nil outgoing tangent, default to 0
---@return spline
function spline:add_point(x, y, z, in_tx, in_ty, in_tz, out_tx, out_ty, out_tz)
	self.points[#self.points + 1] = {
		pos = { x, y, z },
		t_out = { out_tx or 0, out_ty or 0, out_tz or 0 },
		t_in = { in_tx or 0, in_ty or 0, in_tz or 0 },
	}
	return self
end

local function swap_args(swap_count, ...)
	if swap_count > select('#', ...) then
		return ...
	end
	return select(swap_count, ...), swap_args(swap_count + 1, ...)
end

local px,py,pz
local function trigger_call(callback, x,y,z,tx,ty,tz)
	if x == px and y == py and z == pz then return end
	px,py,pz = x,y,z
	return callback(x,y,z,tx,ty,tz)
end

local function subdiv_by_max_angle(spline, max_angle, callback, n, segment, 
								   at, ax, ay, az, atx, aty, atz, 
								   ct, cx, cy, cz, ctx, cty, ctz, ...)
	local bt = (at + ct) * .5
	local bx, by, bz, btx, bty, btz = spline:calc_point(segment, bt)
	local vang = math.pi - vector_angle(bx, by, bz, ax, ay, az, cx, cy, cz)
	local result
	if vang > max_angle and n < 10 then
		result = subdiv_by_max_angle(spline, max_angle, callback, n + 1, segment, 
			at, ax, ay, az, atx, aty, atz, 
			bt, bx, by, bz, btx, bty, btz, ...)
		if result then return result end
		return subdiv_by_max_angle(spline, max_angle, callback, n + 1, segment, 
			bt, bx, by, bz, btx, bty, btz, 
			ct, cx, cy, cz, ctx, cty, ctz, ...)
	else
		result = trigger_call(callback,swap_args(7, ax, ay, az, atx, aty, atz, ...))
		if result then return result end
		if vang > 0.05 then
			result = trigger_call(callback,swap_args(7, bx, by, bz, btx, bty, btz, ...))
			if result then return result end
		end
		result = trigger_call(callback,swap_args(7, cx, cy, cz, ctx, cty, ctz, ...))
		return result
	end
end

function spline:subdivide_by_max_angle(max_angle, callback)
	px,py,pz = nil,nil,nil
	for i = 1, #self.points - 1 do
		local p1 = self.points[i]
		local p2 = self.points[i + 1]
		local x1, y1, z1 = unpack(p1.pos)
		local x2, y2, z2 = unpack(p2.pos)
		local t1x, t1y, t1z = unpack(p1.t_out)
		local t2x, t2y, t2z = unpack(p2.t_in)
		local result
		if t1x == 0 and t1y == 0 and t1z == 0 and t2x == 0 and t2y == 0 and t2z == 0 then
			result = trigger_call(callback,x1, y1, z1, x2 - x1, y2 - y1, z2 - z1)
			if result then return result end
			if i == #self.points - 1 then
				result = trigger_call(callback,x2, y2, z2, x2 - x1, y2 - y1, z2 - z1)
				if result then return result end
			end
		else
			result = subdiv_by_max_angle(self, max_angle, callback, 1, i,
				0, x1, y1, z1, t1x, t1y, t1z, 
				1, x2, y2, z2, -t2x, -t2y, -t2z)
			if result then return result end
		end
	end
end

local px, py, pz, line_width_2, red, green, blue
local function draw_step(x, y, z)
	if px then
		draw_debug_arrow(red, green, blue, px, py, pz, x, y, z, line_width_2)
	end
	px, py, pz = x, y, z
end

function spline:draw_debug(r, g, b, line_width, max_angle)
	max_angle = max_angle or 5 / 180 * math.pi
	px = nil
	red, green, blue = r, g, b
	line_width_2 = line_width
	self:subdivide_by_max_angle(max_angle, draw_step)
end

local len_sum, px, py, pz
local function calc_len(x, y, z)
	if px then
		local dx, dy, dz = px - x, py - y, pz - z
		len_sum = len_sum + (dx * dx + dy * dy + dz * dz) ^ .5
	end
	px, py, pz = x, y, z
end
function spline:calc_length(max_angle)
	max_angle = max_angle or 15 * math.pi / 180
	len_sum = 0
	px, py, pz = nil, nil, nil
	self:subdivide_by_max_angle(max_angle, calc_len)
	return len_sum
end

local remaining_length, px, py, pz, ptx, pty, ptz
local function calc_point_at_distance(x, y, z, tx, ty, tz)
	if px then
		local dx, dy, dz = px - x, py - y, pz - z
		local len = (dx * dx + dy * dy + dz * dz) ^ .5
		if len >= remaining_length then
			local rest = len - remaining_length
			local t = rest / len
			px, py, pz = lerp(1 - t, px, py, pz, x, y, z)
			ptx, pty, ptz = normalize3d(ptx, pty, ptz)
			tx,ty,tz = normalize3d(tx,ty,tz)
			ptx, pty, ptz = normalize3d(lerp(1 - t,ptx, pty, ptz, tx, ty, tz))
			return true
		end
		remaining_length = remaining_length - len
	end
	px, py, pz = x, y, z
	ptx, pty, ptz = tx, ty, tz
end

---@param distance number
---@param max_angle number
---@return number x
---@return number y
---@return number z
---@return number tangent_x
---@return number tangent_y
---@return number tangent_z
function spline:calc_point_at_distance(distance, max_angle)
	max_angle = max_angle or 15 * math.pi / 180
	remaining_length = distance
	px = nil
	self:subdivide_by_max_angle(max_angle, calc_point_at_distance)
	return px, py, pz, ptx, pty, ptz
end

local px,py,pz,seek_z
local function find_value_by_z(x,y,z)
	if px and pz <= seek_z and seek_z <= z then
		local t = (seek_z - pz) / (z - pz)
		px,py,pz = lerp(t,px,py,pz,x,y,z)
		return true
	end
	px,py,pz = x,y,z
end

---Finds the x,y,z values of a spline at coordinate z; Assumes that the spline is linearly going along
---the z direction. The purpose of this function is to be used for splines that describe f(x) math 
---functions; for instance when determining the scaling of an object during an animation.
---@param z number
---@param max_angle number
---@return number
---@return number
---@return number
function spline:find_value_by_z(z, max_angle)
	px,py,pz = nil,nil,nil
	seek_z = z
	self:subdivide_by_max_angle(max_angle, find_value_by_z)
	return px,py,pz
end

---Calculates a point for a specified segment and the interpolation poitn t
---@param segment integer
---@param t number should be ranged between 0 and 1
---@return number|nil x
---@return number|nil y
---@return number|nil z
---@return number|nil tx direction tangent (can be 0)
---@return number|nil ty direction tangent (can be 0)
---@return number|nil tz direction tangent (can be 0)
function spline:calc_point(segment, t, debug)
	if #self.points == 0 then return end
	if #self.points == 1 then
		local x, y, z = unpack(self.points[1].pos)
		return x, y, z, 0, 0, 0
	end
	if segment < 1 then
		segment = 1
		t = 0
	elseif segment >= #self.points then
		segment = #self.points - 1
		t = 1
	end
	segment = clamp(1, #self.points, segment)
	local p1 = self.points[segment]
	local p2 = self.points[segment + 1]
	local x1, y1, z1 = unpack(p1.pos)
	local x2, y2, z2 = unpack(p2.pos)
	local t1x, t1y, t1z = unpack(p1.t_out)
	local t2x, t2y, t2z = unpack(p2.t_in)
	if t1x == 0 and t1y == 0 and t1z == 0 and t2x == 0 and t2y == 0 and t2z == 0 then
		local x, y, z = lerp(t, x1, y1, z1, x2, y2, z2)
		return x, y, z, x2 - x1, y2 - y1, z2 - z1
	end

	local x1t, y1t, z1t = x1 + t1x, y1 + t1y, z1 + t1z
	local x2t, y2t, z2t = x2 + t2x, y2 + t2y, z2 + t2z

	
	local ax, ay, az = lerp(t, x1, y1, z1, x1t, y1t, z1t)
	local bx, by, bz = lerp(t, x1t, y1t, z1t, x2t, y2t, z2t)
	local cx, cy, cz = lerp(t, x2t, y2t, z2t, x2, y2, z2)
	local dx, dy, dz = lerp(t, ax, ay, az, bx, by, bz)
	local ex, ey, ez = lerp(t, bx, by, bz, cx, cy, cz)
	local x, y, z = lerp(t, dx, dy, dz, ex, ey, ez)
	if debug then
		draw_debug_arrow(0,1,0,x1,y1,z1,x1t,y1t,z1t,5)
		draw_debug_arrow(0,1,0,x1t,y1t,z1t,x2t,y2t,z2t,5)
		draw_debug_arrow(0,1,0,x2t,y2t,z2t,x2,y2,z2,5)
		draw_debug_arrow(1,1,0,ax,ay,az,bx,by,bz,5)
		draw_debug_arrow(1,1,0,bx,by,bz,cx,cy,cz,5)
		draw_debug_arrow(1,1,0,dx,dy,dz,ex,ey,ez,5)
	end
	return x, y, z, ex - dx, ey - dy, ez - dz
end

return spline
