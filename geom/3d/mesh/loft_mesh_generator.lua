local mat4x4              = require "love-math.affine.mat4x4"
local dot3d               = require "love-math.geom.3d.dot3d"
local cross               = require "love-math.geom.3d.cross"
local normalize3d         = require "love-math.geom.3d.normalize3d"
local distance            = require "love-math.geom.3d.distance"

---@class loft_mesh_generator : object
---@field path_spline spline the path of the loft to follow
---@field hull_spline spline the hull spline that's swept along the path
---@field scaling_spline spline optional spline that's used for determining x/y scaling of the hull
---@field twisting_spline spline optional spline that's used for determining rotation angle along the path
---@field max_spline_angle number
local loft_mesh_generator = require "love-util.class" "loft_mesh_generator"
function loft_mesh_generator:new(hull_spline, path_spline, max_spline_angle, matrix)
	return self:create {
		path_spline = path_spline,
		hull_spline = hull_spline,
		max_spline_angle = max_spline_angle or 10 / 180 * math.pi,
		color = {1,1,1,1},
		matrix = matrix or mat4x4:new(),
	}
end

function loft_mesh_generator:set_scaling_spline(scaling_spline)
	self.scaling_spline = scaling_spline
	return self
end

function loft_mesh_generator:set_twisting_spline(twisting_spline)
	self.twisting_spline = twisting_spline
	return self
end

local function spline_to_points(spline, max_angle)
	local points = {}
	local tangents = {}
	local distances = {0}
	local total_distance = 0
	local px,py,pz
	spline:subdivide_by_max_angle(max_angle, function(x, y, z, tx,ty,tz)
		if px then
			local d = distance(x,y,z,px,py,pz)
			total_distance = total_distance + d
			distances[#distances+1] = total_distance
		end
		px,py,pz = x,y,z
		points[#points + 1] = x
		points[#points + 1] = y
		points[#points + 1] = z
		tangents[#tangents+1] = tx
		tangents[#tangents+1] = ty
		tangents[#tangents+1] = tz
	end)
	for i=1,#distances do
		distances[i] = distances[i] / total_distance
	end
	return points,tangents,distances
end

local m_tmp = mat4x4:new()
local m_tmp2 = mat4x4:new()
---@param mesh_builder mesh_builder
function loft_mesh_generator:generate(mesh_builder)
	local hull_points, hull_tangents, hull_uv = spline_to_points(self.hull_spline, self.max_spline_angle)
	local path_points, path_tangents, path_uv = spline_to_points(self.path_spline, self.max_spline_angle)
	
	local ring_points = {}
	local prev_ring_points
	-- initial up vector to use - gets modified while sweeping along the path to avoid flipping directions
	local upx, upy, upz = 0, 1, 0
	for i = 1, #path_points, 3 do
		-- x2,y2,z2 is our pivot; x1,y1,z1 and x3,y3,z3 is used for direction alignment (computing forward)
		local x1, y1, z1, x2, y2, z2, x3, y3, z3 = unpack(path_points, i - 3)
		-- there may be no previous / next point - following code extrapolates the direction from
		-- previous / next point along the path. May be better to use the tangents, but not sure 🤷‍♂️
		if not x1 then
			x1, y1, z1 = x2 * 2 - x3, y2 * 2 - y3, z2 * 2 - z3
		end
		if not x3 then
			x3, y3, z3 = x2 * 2 - x1, y2 * 2 - y1, z2 * 2 - z1
		end
		local dx, dy, dz = x3 - x1, y3 - y1, z3 - z1
		
		-- computing the dot product to figure out if the our up vector is colinear with the direction
		local dot = dot3d(dx, dy, dz, upx, upy, upz)
		if dot == 1 or dot == -1 then
			-- flipping one component to have a defined up vector
			upx, upy, upz = upy, upx, upz
		end

		-- compute left, up and forward vectors
		local lx, ly, lz = normalize3d(cross(dx, dy, dz, upx, upy, upz))
		local ux, uy, uz = normalize3d(cross(lx, ly, lz, dx, dy, dz))
		local fx, fy, fz = normalize3d(dx, dy, dz)
		
		-- computing scale factor (if there's a scale determining spline)
		local v = path_uv[(i-1)/3+1];
		local scale_x, scale_y = 1,1
		if self.scaling_spline then
			 scale_x, scale_y = self.scaling_spline:find_value_by_z(v, self.max_spline_angle)
		end

		-- construct a matrix to translate the position of the hull into local coordinates of the
		-- point we're along the path
		m_tmp:set_position(x2, y2, z2)
			:set_x(lx * scale_x, ly * scale_x, lz * scale_x)
			:set_y(ux * scale_y, uy * scale_y, uz * scale_y)
			:set_z(fx, fy, fz)
		
		-- apply optional twisting
		if self.twisting_spline then
			local twist = self.twisting_spline:find_value_by_z(v, self.max_spline_angle)
			m_tmp2:identity():set_rotate_axis(twist,0,0,1)
			m_tmp:multiply(m_tmp2)
		end

		-- produce the hull point mesh points
		for j = 1, #hull_points, 3 do
			local hx1, hy1, hz1 = unpack(hull_points, j)
			local htx1, hty1, htz1 = unpack(hull_tangents, j)

			-- translating point and tangent into "local" space of the path using the matrix
			hx1, hy1, hz1 = m_tmp:multiply_point(hx1, hy1, hz1)
			htx1, hty1, htz1 = m_tmp:multiply_dir(htx1, hty1, htz1)

			local id = mesh_builder:allocate_vertices(1)
			ring_points[#ring_points+1] = id

			-- computing the normal via cross product of forward and tangent
			local nx,ny,nz = normalize3d(cross(fx,fy,fz,htx1,hty1,htz1))
			local u = hull_uv[(j-1)/3+1]
			self:set_vertice(mesh_builder,id,hx1, hy1,hz1, u, v, nx,ny,nz)
		end
		
		-- add the needed triangles
		if prev_ring_points then
			for i=1,#ring_points-1 do
				mesh_builder:add_triangles(ring_points[i+1], ring_points[i],prev_ring_points[i])
				mesh_builder:add_triangles(ring_points[i+1], prev_ring_points[i],prev_ring_points[i+1])
			end
		end
		prev_ring_points = ring_points
		ring_points = {}

		-- update the up vector (which is perpendicular to the current path position) to avoid flips
		upx, upy, upz = ux, uy, uz
	end
end

function loft_mesh_generator:set_vertice(mesh_builder, id, x, y, z, u, v, nx, ny, nz)
	assert(u and v)
	assert(x and y and z)
	assert(nx and ny and nz)
	mesh_builder:set_color(id, unpack(self.color))
	mesh_builder:set_normal(id, self.matrix:multiply_dir(nx, ny, nz))
	mesh_builder:set_position(id, self.matrix:multiply_point(x, y, z))
	mesh_builder:set_uv(id, u, v)
	return self
end


return loft_mesh_generator
