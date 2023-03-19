local mat4x4 = require "love-math.affine.mat4x4"

---@class cylinder_mesh_generator : object
local cylinder_mesh_generator = require "love-util.class" "cylinder_mesh_generator"

function cylinder_mesh_generator:new(mat, radius, height, subdivisions, has_top, has_bottom, color)
	return self:create {
		matrix = mat4x4:new():copy(mat),
		radius = radius,
		height = height,
		subdivisions = subdivisions,
		has_top = has_top,
		has_bottom = has_bottom,
		bottom_radius_scale = 1,
		top_radius_scale = 1,
		color = color or { 1, 1, 1, 1 }
	}
end

function cylinder_mesh_generator:set_radius(radius)
	self.radius = radius
	return self
end

function cylinder_mesh_generator:set_height(height)
	self.height = height
	return self
end

function cylinder_mesh_generator:set_bottom_radius_scale(scale)
	self.bottom_radius_scale = scale
	return self
end

function cylinder_mesh_generator:set_top_radius_scale(scale)
	self.top_radius_scale = scale
	return self
end

---@param mesh_builder mesh_builder
function cylinder_mesh_generator:generate(mesh_builder)
	local subdivs = self.subdivisions
	local radius_top = self.radius * self.top_radius_scale
	local radius_bottom = self.radius * self.bottom_radius_scale
	local half_height = self.height / 2
	local prev_bottom, prev_top, prev_cap_top, prev_cap_bottom
	local center_bottom, center_top = mesh_builder:allocate_vertices(2)
	local u, v = .5, .5
	self:set_vertice(mesh_builder, center_bottom, 0, -half_height, 0, u, v, 0, -1, 0)
	self:set_vertice(mesh_builder, center_top, 0, half_height, 0, u, v, 0, 1, 0)
	-- print("??",center_bottom, center_top)
	for i = 0, subdivs do
		local u = i / subdivs
		local angle = math.pi * i / subdivs * 2
		local nx, nz = math.sin(angle), math.cos(angle)
		local ny = (radius_bottom - radius_top) / self.height
		local x_top, z_top = nx * radius_top, nz * radius_top
		local x_bottom, z_bottom = nx * radius_bottom, nz * radius_bottom
		local bottom, top = mesh_builder:allocate_vertices(2)
		-- print(bottom,top)
		self:set_vertice(mesh_builder, bottom, x_bottom, -half_height, z_bottom, u, 0, nx, ny, nz)
		self:set_vertice(mesh_builder, top, x_top, half_height, z_top, u, 1, nx, ny, nz)
		local cap_bottom, cap_top = mesh_builder:allocate_vertices(2)
		local u, v = nx * .5 + .5, nz * .5 + .5
		self:set_vertice(mesh_builder, cap_bottom, x_bottom, -half_height, z_bottom, u, v, 0, -1, 0)
		self:set_vertice(mesh_builder, cap_top, x_top, half_height, z_top, u, v, 0, 1, 0)
		if i > 0 then
			if self.has_top and radius_top ~= 0 then
				mesh_builder:add_triangles(cap_top, prev_cap_top, center_top)
			end
			if self.has_bottom and radius_bottom ~= 0 then
				mesh_builder:add_triangles(prev_cap_bottom, cap_bottom, center_bottom)
			end
			if radius_top == 0 then
				mesh_builder:add_triangles(prev_bottom, top, bottom)
			elseif radius_bottom == 0 then
			else
				mesh_builder:add_triangles(prev_bottom, prev_top, top, prev_bottom, top, bottom)
			end
		end
		prev_bottom, prev_top = bottom, top
		prev_cap_bottom, prev_cap_top = cap_bottom, cap_top
	end
end

function cylinder_mesh_generator:set_vertice(mesh_builder, id, x, y, z, u, v, nx, ny, nz)
	assert(u and v)
	assert(x and y and z)
	assert(nx and ny and nz)
	mesh_builder:set_color(id, unpack(self.color))
	mesh_builder:set_normal(id, self.matrix:multiply_dir(nx, ny, nz))
	mesh_builder:set_position(id, self.matrix:multiply_point(x, y, z))
	mesh_builder:set_uv(id, u, v)
	-- local vertice_data_count = #mesh_builder.vertices / mesh_builder.vertice_size

	-- -- print(id,x,y,z,u,v,nx,ny,nz)
	-- assert(vertice_data_count == #mesh_builder.uvs / mesh_builder.uv_size, "#uvs="..(#mesh_builder.uvs / mesh_builder.uv_size).." vertice_data_count="..vertice_data_count)

	return self
end

return cylinder_mesh_generator
