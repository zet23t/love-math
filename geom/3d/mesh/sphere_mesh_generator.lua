local mat4x4 = require "love-math.affine.mat4x4"

---@class sphere_mesh_generator : object
local sphere_mesh_generator = require "love-util.class" "sphere_mesh_generator"

function sphere_mesh_generator:new(mat, radius, subdivisions_u, subdivisions_v)
	return self:create {
		matrix = mat4x4:new():copy(mat),
		radius = radius,
		subdivisions_u = subdivisions_u or 12,
		subdivisions_v = subdivisions_v or 12,
		color = { 1, 1, 1, 1 },
	}
end

---@param mesh_builder mesh_builder
function sphere_mesh_generator:generate(mesh_builder)
	local radius = self.radius
	for subdiv_v = 0, self.subdivisions_v - 1 do
		local lin_v0 = subdiv_v / self.subdivisions_v
		local lin_v1 = (subdiv_v + 1) / self.subdivisions_v
		local angle_v0 = lin_v0 * math.pi 
		local angle_v1 = lin_v1 * math.pi 
		local v0 = math.cos(angle_v0)
		local v1 = math.cos(angle_v1)
		local r0 = math.sin(angle_v0)
		local r1 = math.sin(angle_v1)
		for subdiv_u = 0, self.subdivisions_u - 1 do
			local lin_u0 = subdiv_u / self.subdivisions_u
			local lin_u1 = (subdiv_u+1) / self.subdivisions_u
			local angle_u0 = lin_u0 * math.pi * 2
			local angle_u1 = lin_u1 * math.pi * 2
			local u0 = math.cos(angle_u0)
			local u1 = math.cos(angle_u1)
			local z0 = math.sin(angle_u0)
			local z1 = math.sin(angle_u1)
			local a, b, c, d = mesh_builder:allocate_vertices(4)
			local nx0, ny0, nz0 = u0, v0, z0
			local nx1, ny1, nz1 = u1, v1, z1
			local x0, y0, z0 = nx0 * radius, ny0 * radius, nz0 * radius
			local x1, y1, z1 = nx1 * radius, ny1 * radius, nz1 * radius
			self:set_vertice(mesh_builder, a, x0 * r0, y0, z0 * r0, lin_u0, lin_v0, nx0, ny0, nz0)
			self:set_vertice(mesh_builder, b, x0 * r1, y1, z0 * r1, lin_u0, lin_v1, nx0, ny1, nz0)
			self:set_vertice(mesh_builder, c, x1 * r1, y1, z1 * r1, lin_u1, lin_v1, nx1, ny1, nz1)
			self:set_vertice(mesh_builder, d, x1 * r0, y0, z1 * r0, lin_u1, lin_v0, nx1, ny0, nz1)
			if subdiv_v <= self.subdivisions_v - 1 then
				mesh_builder:add_triangles(a, b, c)
			end
			if subdiv_v <= self.subdivisions_v - 1 then
				mesh_builder:add_triangles(a, c, d)
			end
		end
	end
end

function sphere_mesh_generator:set_vertice(mesh_builder, id, x, y, z, u, v, nx, ny, nz)
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

return sphere_mesh_generator
