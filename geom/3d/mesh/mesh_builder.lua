---@class mesh_builder : object
---@field vertice_counter integer
---@field uvs number[]
---@field uv_size integer
---@field vertices number[]
---@field vertice_size integer
---@field normals number[]
---@field normal_size integer
---@field colors number[]
---@field color_size integer
---@field triangles integer[]
local mesh_builder = require "love-util.class" "mesh_builder"
local cross        = require "love-math.geom.3d.cross"
local normalize3d  = require "love-math.geom.3d.normalize3d"
local vector_angle = require "love-math.geom.3d.vector_angle"
local length3d     = require "love-math.geom.3d.length3d"

function mesh_builder:new()
	return self:create {
		vertice_counter = 0,
		uvs = {},
		uv_size = 2,
		vertices = {},
		vertice_size = 3,
		normals = {},
		normal_size = 3,
		colors = {},
		color_size = 4,
		triangles = {},
	}
end

local function unpack_number_range(list, from, to)
	if from == to then return list[from] or 0 end
	return list[from] or 0, unpack_number_range(list, from + 1, to)
end

local function setVertexAttribute(mesh, vertice_count, attribute_index, data_size, data)
	if attribute_index then
		for i = 1, vertice_count do
			mesh:setVertexAttribute(i, attribute_index,
				unpack_number_range(data, (i - 1) * data_size + 1, i * data_size))
		end
	end
end

---Returns a new vertice that can be used for vertice data
---@param amount integer|nil the number of vertices to allocate
---@return integer
---@return ...
function mesh_builder:allocate_vertices(amount)
	self.vertice_counter = self.vertice_counter + 1
	if amount and amount > 1 then
		return self.vertice_counter, self:allocate_vertices(amount - 1)
	end

	return self.vertice_counter
end

local function get_data(data, index, size)
	local idx = (index - 1) * size + 1
	return unpack(data, idx, idx + size - 1)
end

function mesh_builder:allocate_from_vertice(source_id)
	self.vertice_counter = self.vertice_counter + 1
	local new_id = self.vertice_counter
	self:set_position(new_id, get_data(self.vertices, source_id, self.vertice_size))
	self:set_normal(new_id, get_data(self.normals, source_id, self.normal_size))
	self:set_color(new_id, get_data(self.colors, source_id, self.color_size))
	self:set_uv(new_id, get_data(self.uvs, source_id, self.uv_size))
	return new_id
end

local function set_data(vertice_id, size, list, ...)
	if size <= 0 then return end
	local idx = (vertice_id - 1) * size
	for i = 1, size do
		local num = select(i, ...)
		-- nan check
		assert(num == num)
		list[idx + i] = num
	end
end

---@param vertice_id integer
---@param ... number
---@return mesh_builder
function mesh_builder:set_position(vertice_id, ...)
	set_data(vertice_id, self.vertice_size, self.vertices, ...)
	return self
end

---@param vertice_id integer
---@param ... number
---@return mesh_builder
function mesh_builder:set_uv(vertice_id, ...)
	set_data(vertice_id, self.uv_size, self.uvs, ...)
	return self
end

---@param vertice_id integer
---@param ... number
---@return mesh_builder
function mesh_builder:set_normal(vertice_id, ...)
	set_data(vertice_id, self.normal_size, self.normals, ...)
	return self
end

---@param vertice_id integer
---@param ... number
---@return mesh_builder
function mesh_builder:set_color(vertice_id, ...)
	set_data(vertice_id, self.color_size, self.colors, ...)
	return self
end

---Adds triangles to the list of triangles
---@param vertice_id_a integer
---@param vertice_id_b integer
---@param vertice_id_c integer
---@param ... integer
---@return mesh_builder
function mesh_builder:add_triangles(vertice_id_a, vertice_id_b, vertice_id_c, ...)
	self.triangles[#self.triangles + 1] = vertice_id_a
	self.triangles[#self.triangles + 1] = vertice_id_b
	self.triangles[#self.triangles + 1] = vertice_id_c
	if ... then
		return self:add_triangles(...)
	end
	return self
end

local function to_zero(x)
	-- signed zeros are the worst
	return math.abs(x) < 0.00001 and 0 or x
end

local function cut_bits(x, y, z)
	x, y, z = to_zero(x), to_zero(y), to_zero(z)
	return math.floor(x * 0x10000), math.floor(y * 0x10000), math.floor(z * 0x10000)
end

function mesh_builder:recalculate_normals(max_angle_radians)
	local vertice_pos_info = {}
	local triangle_normals = {}

	local function add_triangle_vertice(vertice_id, x, y, z, triangle_id, nx, ny, nz)
		x, y, z = cut_bits(x, y, z)
		local pos_key = x .. " " .. y .. " " .. z
		local v = vertice_pos_info[pos_key]
		local tid = (triangle_id - 1) * 3 + 1
		triangle_normals[tid] = nx
		triangle_normals[tid + 1] = ny
		triangle_normals[tid + 2] = nz
		if not v then
			vertice_pos_info[pos_key] = { triangle_id, vertice_id }
		else
			v[#v + 1] = triangle_id
			v[#v + 1] = vertice_id
		end
		return add_triangle_vertice
	end

	for i = 1, #self.triangles, 3 do
		local a, b, c = unpack(self.triangles, i, i + 2)
		local ia, ib, ic = (a - 1) * 3 + 1, (b - 1) * 3 + 1, (c - 1) * 3 + 1
		local ax, ay, az = unpack(self.vertices, ia, ia + 2)
		local bx, by, bz = unpack(self.vertices, ib, ib + 2)
		local cx, cy, cz = unpack(self.vertices, ic, ic + 2)
		local nx, ny, nz = normalize3d(cross(bx - cx, by - cy, bz - cz, ax - cx, ay - cy, az - cz))

		add_triangle_vertice(a, ax, ay, az, i, nx, ny, nz)(b, bx, by, bz, i + 1, nx, ny, nz)(c, cx, cy, cz, i + 2, nx, ny,
			nz)
	end

	for k, v in pairs(vertice_pos_info) do
		if #v > 2 then
			local nx, ny, nz = 0, 0, 0
			for i = 1, #v, 2 do
				local id = (v[i] - 1) * 3 + 1
				local tnx, tny, tnz = unpack(triangle_normals, id, id + 2)
				nx, ny, nz = nx + tnx, ny + tny, nz + tnz
			end
			nx, ny, nz = normalize3d(nx, ny, nz)
			for i = 1, #v, 2 do
				local triangle_id, vertex_index = v[i], v[i + 1]
				local atid = (triangle_id - 1) * 3 + 1
				local atnx, atny, atnz = unpack(triangle_normals, atid, atid + 2)
				local nx, ny, nz = atnx, atny, atnz
				for j = 1, #v, 2 do
					if j ~= i then
						local btid = (v[j] - 1) * 3 + 1
						local btnx, btny, btnz = unpack(triangle_normals, btid, btid + 2)
						local angle = vector_angle(0, 0, 0, atnx, atny, atnz, btnx, btny, btnz)
						if angle < max_angle_radians then
							nx, ny, nz = nx + btnx, ny + btny, nz + btnz
						end
					end
				end
				nx, ny, nz = normalize3d(nx, ny, nz)
				local new_id = self:allocate_from_vertice(vertex_index)
				self.triangles[triangle_id] = new_id
				self:set_normal(new_id, nx, ny, nz)
			end
		end
	end

	return self:optimize()
end

function mesh_builder:optimize()
	-- TODO:
	-- - delete vertices not used by triangles
	-- - merge vertices with nearly same position / uv / color / normal
	return self
end

---creates a new mesh using the data from the inputs
---@return love.Mesh
function mesh_builder:create_mesh()
	local vertice_count = self.vertice_counter
	-- assert(vertice_count%1 == 0, "vertice_data_count = "..vertice_count.."; "..#self.vertices)
	local attribute_normal_index, attribute_uv_index, attribute_color_index
	local attributes = { { "VertexPosition", "float", self.vertice_size } }
	if #self.normals > 0 then
		-- assert(vertice_data_count == #self.normals / self.normal_size)
		attributes[#attributes + 1] = { "VertexNormal", "float", self.normal_size }
		attribute_normal_index = #attributes
	end
	if #self.uvs > 0 then
		-- assert(vertice_data_count == #self.uvs / self.uv_size, "#uvs="..(#self.uvs / self.uv_size).." vertice_data_count="..vertice_data_count)
		attributes[#attributes + 1] = { "VertexTexCoord", "float", self.uv_size }
		attribute_uv_index = #attributes
	end
	if #self.colors > 0 then
		-- assert(vertice_data_count == #self.colors / self.color_size)
		attributes[#attributes + 1] = { "VertexColor", "float", self.color_size }
		attribute_color_index = #attributes
	end

	local mesh = love.graphics.newMesh(attributes, math.max(1, self.vertice_counter), "triangles", "static")
	setVertexAttribute(mesh, vertice_count, 1, self.vertice_size, self.vertices)
	setVertexAttribute(mesh, vertice_count, attribute_normal_index, self.normal_size, self.normals)
	setVertexAttribute(mesh, vertice_count, attribute_uv_index, self.uv_size, self.uvs)
	setVertexAttribute(mesh, vertice_count, attribute_color_index, self.color_size, self.colors)
	if #self.triangles > 0 then
		mesh:setVertexMap(self.triangles)
	else
		mesh:setDrawRange()
	end

	return mesh
end

return mesh_builder
