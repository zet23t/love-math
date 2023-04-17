local ffi                               = require "ffi"
local clipper                           = require "love-math.geom.2d.shape.clipper"
local add                               = require "love-util.add"
local find_segment_segment_intersection = require "love-math.geom.2d.find_segment_segment_intersection"
local gizmo_lines                       = require "mod3d.gizmo_lines"


---@class polygon_shape : object
---@field polygons number[][]
local polygon_shape = require "love-util.class" "polygon_shape"
local scale = 0x1000
local inv_scale = 1 / scale


function polygon_shape:new()
	return self:create {
		polygons = clipper.polygons()
	}
end

local function poly_rect(mat, width, height)
	width, height = width * .5, height * .5
	local x1, y1 = mat:multiply_point(-width, -height, 0)
	local x2, y2 = mat:multiply_point(-width, height, 0)
	local x3, y3 = mat:multiply_point(width, height, 0)
	local x4, y4 = mat:multiply_point(width, -height, 0)

	local poly = clipper.polygon()
	poly:add(x1 * scale, y1 * scale)
	poly:add(x2 * scale, y2 * scale)
	poly:add(x3 * scale, y3 * scale)
	poly:add(x4 * scale, y4 * scale)
	return poly
end

local function handle_poly(self, poly, operation)
	if self.polygons:size() < 1 then
		self.polygons:add(poly)
		return self
	end
	local clipper_exec = clipper.new()
	clipper_exec:add_subject(self.polygons)
	clipper_exec:add_clip(poly)

	self.polygons = clipper_exec:execute(operation)

	-- add(self.polygons, add({}, x1, y1, x2, y2, x3, y3, x4, y4))
	return self
end

---@param mat mat4x4
---@param width number
---@param height number
function polygon_shape:add_rectangle(mat, width, height)
	return handle_poly(self, poly_rect(mat, width, height), "union")
end

---@param mat mat4x4
---@param width number
---@param height number
function polygon_shape:subtract_rectangle(mat, width, height)
	return handle_poly(self, poly_rect(mat, width, height), "difference")
end

---@param mat mat4x4
---@param width number
---@param height number
function polygon_shape:intersect_rectangle(mat, width, height)
	return handle_poly(self, poly_rect(mat, width, height), "intersection")
end

function polygon_shape:add_circle(mat, radius, divisions_per_rad)
end

function polygon_shape:add_arc(mat, radius1, radius2, angle1, angle2, close_mode)
end

function polygon_shape:add_spline(mat, spline)

end

function polygon_shape:union(shape)
end

function polygon_shape:subtract(shape)
end

function polygon_shape:intersect(shape)
end

local function is_point_inside_triangle(x, y, x1, y1, x2, y2, x3, y3)
	local a = x2 - x1
	local b = y2 - y1
	local c = x3 - x1
	local d = y3 - y1
	local e = x - x1
	local f = y - y1

	-- Calculate the barycentric coordinates of the point using precomputed values
	local det = a * d - b * c
	local w1 = (d * e - c * f) / det
	local w2 = (-b * e + a * f) / det
	local w3 = 1 - w1 - w2

	-- Check if the barycentric coordinates are all positive
	return w1 >= 0 and w2 >= 0 and w3 >= 0
end

local function poly_to_points(poly)
	local points = {}
	for j = 1, poly:size() do
		local p = poly:get(j)
		local x, y = tonumber(p.x) * inv_scale, tonumber(p.y) * inv_scale
		add(points, x, y)
	end
	return points
end

local function add_triangulation(triangles, ps)
	local ts = love.math.triangulate(ps)
	for i = 1, #ts do
		add(triangles, ts[i])
	end
end

function polygon_shape:triangulate()
	local triangles = {}
	for i = 1, self.polygons:size() do
		local poly = self.polygons:get(i)
		local is_positive = poly:orientation()
		local points = poly_to_points(poly)
		if not is_positive then
			for j = #triangles, 1, -1 do
				local x1, y1, x2, y2, x3, y3 = unpack(triangles[j])

				for k = 1, #points, 2 do
					local ax, ay = points[k], points[k + 1]
					if is_point_inside_triangle(ax, ay, x1, y1, x2, y2, x3, y3) then
						table.remove(triangles, j)
						if k == 1 then
							local contained = true
							for l = 3, #points, 2 do
								local ax, ay = points[l], points[l + 1]
								if not is_point_inside_triangle(ax, ay, x1, y1, x2, y2, x3, y3) then
									contained = false
									break
								end
							end
							if contained then
								local lowest_x, lowest_i = points[1], 1
								for l = 3, #points, 2 do
									local ax = points[l]
									if ax < lowest_x then
										lowest_x, lowest_i = ax, l
									end
								end
								-- lowest_i = (lowest_i + 1) % #points + 1
								while lowest_i > 1 do
									local x = table.remove(points, 1)
									local y = table.remove(points, 1)
									add(points, x, y)
									lowest_i = lowest_i - 2
								end
								if x2 < x1 then
									x1, y1, x2, y2, x3, y3 = x2, y2, x3, y3, x1, y1
								end
								if x3 < x1 then
									x1, y1, x2, y2, x3, y3 = x3, y3, x1, y1, x2, y2
								end
								add(points, points[1], points[2])
								table.insert(points, 1, y1)
								table.insert(points, 1, x1)
								add(points, x1,y1, x2, y2, x3, y3, x1, y1)
								add_triangulation(triangles, points)
								break
							end
						end
						local clipex = clipper.new()
						local tri = clipper.polygon()
						tri:add(x1 * scale, y1 * scale)
						tri:add(x2 * scale, y2 * scale)
						tri:add(x3 * scale, y3 * scale)
						clipex:add_subject(tri)
						clipex:add_clip(poly)
						local polys = clipex:execute("difference")
						for l = 1, polys:size() do
							local p = polys:get(l)
							local ps = poly_to_points(p)
							add_triangulation(triangles, ps)
						end
						break
					end
					
					local n = (k + 1) % #points + 1
					local bx, by = points[n], points[n + 1]
					if find_segment_segment_intersection(ax,ay,x1,y1,x2,y2,x3,y3) then
						table.remove(triangles, j)
						local clipex = clipper.new()
						local tri = clipper.polygon()
						tri:add(x1 * scale, y1 * scale)
						tri:add(x2 * scale, y2 * scale)
						tri:add(x3 * scale, y3 * scale)
						clipex:add_subject(tri)
						clipex:add_clip(poly)
						local polys = clipex:execute("difference")
						for l = 1, polys:size() do
							local p = polys:get(l)
							local ps = poly_to_points(p)
							add_triangulation(triangles, ps)
						end
						break
					end
				end
			end
		else
			local suc, tris = pcall(love.math.triangulate, points)
			if suc then
				for i = 1, #tris do
					add(triangles, tris[i])
				end
			else
				return {}
			end
		end
	end
	return triangles
end

function polygon_shape:offset(distance, joint_mode, joint_angle)
end

return polygon_shape
