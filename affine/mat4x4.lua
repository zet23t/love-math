local normalize3d = require "love-math.geom.3d.normalize3d"
---@class mat4x4 A 4x4 matrix for affine transformations
local mat4x4 = {}
mat4x4._mt = { __index = mat4x4 }

---@return mat4x4
function mat4x4:new()
	return setmetatable({
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	}, self._mt)
end

local m_tmp = mat4x4:new()

---@return mat4x4
function mat4x4:identity()
	self[1], self[2], self[3], self[4],
	self[5], self[6], self[7], self[8],
	self[9], self[10], self[11], self[12],
	self[13], self[14], self[15], self[16] =
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	return self
end

---@return mat4x4
function mat4x4:clone()
	return setmetatable({ unpack(self) }, self._mt)
end

function mat4x4:get_x(s)
	s = s or 1
	return self[1] * s, self[5] * s, self[9] * s
end

function mat4x4:get_y(s)
	s = s or 1
	return self[2] * s, self[6] * s, self[10] * s
end

function mat4x4:get_z(s)
	s = s or 1
	return self[3] * s, self[7] * s, self[11] * s
end

function mat4x4:set_x(x, y, z)
	self[1], self[5], self[9] = x, y, z
	return self
end

function mat4x4:set_y(x, y, z)
	self[2], self[6], self[10] = x, y, z
	return self
end

function mat4x4:set_z(x, y, z)
	self[3], self[7], self[11] = x, y, z
	return self
end

function mat4x4:set_row_x(x, y, z)
	self[1], self[2], self[3] = x, y, z
	return self
end

function mat4x4:set_row_y(x, y, z)
	self[5], self[6], self[7] = x, y, z
	return self
end

function mat4x4:set_row_z(x, y, z)
	self[9], self[10], self[11] = x, y, z
	return self
end

function mat4x4:get_row_x(s)
	s = s or 1
	return self[1] * s, self[2] * s, self[3] * s
end

function mat4x4:get_row_y(s)
	s = s or 1
	return self[5] * s, self[6] * s, self[7] * s
end

function mat4x4:get_row_z(s)
	s = s or 1
	return self[9] * s, self[10] * s, self[11] * s
end

function mat4x4:get_position(s)
	s = s or 1
	return self[4] * s, self[8] * s, self[12] * s
end

function mat4x4:transpose()
	self[1], self[2], self[3], self[4],
	self[5], self[6], self[7], self[8],
	self[9], self[10], self[11], self[12],
	self[13], self[14], self[15], self[16] =
		self[1], self[5], self[9], self[13],
		self[2], self[6], self[10], self[14],
		self[3], self[7], self[11], self[15],
		self[4], self[8], self[12], self[16]
	return self
end

function mat4x4:copy(m)
	self[1], self[2], self[3], self[4],
	self[5], self[6], self[7], self[8],
	self[9], self[10], self[11], self[12],
	self[13], self[14], self[15], self[16] =
		m[1], m[2], m[3], m[4],
		m[5], m[6], m[7], m[8],
		m[9], m[10], m[11], m[12],
		m[13], m[14], m[15], m[16]
	return self
end

function mat4x4:translate(x, y, z)
	x = x or 0
	y = y or x
	z = z or y
	self[4] = self[4] + x
	self[8] = self[8] + y
	self[12] = self[12] + z
	return self
end

function mat4x4:set_position(x, y, z)
	x = x or 0
	y = y or x
	z = z or y
	self[4] = x
	self[8] = y
	self[12] = z
	return self
end

function mat4x4:set_object_scale(x, y, z)
	self[1], self[5], self[9] = normalize3d(self[1], self[5], self[9], x)
	self[2], self[6], self[10] = normalize3d(self[2], self[6], self[10], y or x)
	self[3], self[7], self[11] = normalize3d(self[3], self[7], self[11], z or y or x)
	return self
end

function mat4x4:scale(x, y, z)
	self[1], self[5], self[9],
	self[2], self[6], self[10],
	self[3], self[7], self[11] =
		self[1] * x, self[5] * y, self[9] * z,
		self[2] * x, self[6] * y, self[10] * z,
		self[3] * x, self[7] * y, self[11] * z
	return self
end

function mat4x4:set_y_rot(radians)
	local s, c = math.sin(radians), math.cos(radians)
	self[1], self[3] = s, -c
	self[9], self[11] = c, s
	return self
end

function mat4x4:rotate_axis(radians, ax, ay, az)
	m_tmp:identity():set_rotate_axis(radians, ax, ay, az)
	self:multiply(m_tmp)
	return self
end

function mat4x4:set_rotate_axis(radians, ax, ay, az)
	local s, c = math.sin(radians), math.cos(radians)
	local invc = 1.0 - c
	local length = ax * ax + ay * ay + az * az
	if length > 1.0001 or length < 0.9999 then
		length = length ^ .5
		ax, ay, az = ax / length, ay / length, az / length
	end

	local x  = ax * invc
	local y  = ay * invc
	local z  = az * invc

	self[1]  = c + x * ax
	self[2]  = x * ay + s * az
	self[3]  = x * az - s * ay

	self[5]  = y * ax - s * az
	self[6]  = c + y * ay
	self[7]  = y * az + s * ax

	self[9]  = z * ax + s * ay
	self[10] = z * ay - s * ax
	self[11] = c + z * az

	return self
end

function mat4x4:ortho(width, height, n, f)
	self[1], self[2], self[3], self[4],
	self[5], self[6], self[7], self[8],
	self[9], self[10], self[11], self[12],
	self[13], self[14], self[15], self[16] =
		-n / width, 0, 0, 0,
		0, -n / height, 0, 0,
		0, 0, -(f + n) / (f - n), f * n / (f - n),
		0, 0, -1, 0
	return self
end

function mat4x4:perspective(fov, aspect, near, far)
	local top                              = near * math.tan(fov * math.pi / 180 / 2)
	local bottom                           = -1 * top
	local right                            = top * aspect
	local left                             = -1 * right

	self[1], self[2], self[3], self[4]     = 2 * near / (right - left), 0, (right + left) / (right - left), 0
	self[5], self[6], self[7], self[8]     = 0, 2 * near / (top - bottom), (top + bottom) / (top - bottom), 0
	self[9], self[10], self[11], self[12]  = 0, 0, -1 * (far + near) / (far - near), -2 * far * near / (far - near)
	self[13], self[14], self[15], self[16] = 0, 0, -1, 0
	return self
end

function mat4x4:multiply(a)
	local b = self
	self[1], self[2], self[3], self[4],
	self[5], self[6], self[7], self[8],
	self[9], self[10], self[11], self[12],
	self[13], self[14], self[15], self[16] =
		b[1] * a[1] + b[2] * a[5] + b[3] * a[9] + b[4] * a[13],
		b[1] * a[2] + b[2] * a[6] + b[3] * a[10] + b[4] * a[14],
		b[1] * a[3] + b[2] * a[7] + b[3] * a[11] + b[4] * a[15],
		b[1] * a[4] + b[2] * a[8] + b[3] * a[12] + b[4] * a[16],
		b[5] * a[1] + b[6] * a[5] + b[7] * a[9] + b[8] * a[13],
		b[5] * a[2] + b[6] * a[6] + b[7] * a[10] + b[8] * a[14],
		b[5] * a[3] + b[6] * a[7] + b[7] * a[11] + b[8] * a[15],
		b[5] * a[4] + b[6] * a[8] + b[7] * a[12] + b[8] * a[16],
		b[9] * a[1] + b[10] * a[5] + b[11] * a[9] + b[12] * a[13],
		b[9] * a[2] + b[10] * a[6] + b[11] * a[10] + b[12] * a[14],
		b[9] * a[3] + b[10] * a[7] + b[11] * a[11] + b[12] * a[15],
		b[9] * a[4] + b[10] * a[8] + b[11] * a[12] + b[12] * a[16],
		b[13] * a[1] + b[14] * a[5] + b[15] * a[9] + b[16] * a[13],
		b[13] * a[2] + b[14] * a[6] + b[15] * a[10] + b[16] * a[14],
		b[13] * a[3] + b[14] * a[7] + b[15] * a[11] + b[16] * a[15],
		b[13] * a[4] + b[14] * a[8] + b[15] * a[12] + b[16] * a[16]

	return self
end

function mat4x4:multiply_left(b)
	local a = self
	self[1], self[2], self[3], self[4],
	self[5], self[6], self[7], self[8],
	self[9], self[10], self[11], self[12],
	self[13], self[14], self[15], self[16] =
		b[1] * a[1] + b[2] * a[5] + b[3] * a[9] + b[4] * a[13],
		b[1] * a[2] + b[2] * a[6] + b[3] * a[10] + b[4] * a[14],
		b[1] * a[3] + b[2] * a[7] + b[3] * a[11] + b[4] * a[15],
		b[1] * a[4] + b[2] * a[8] + b[3] * a[12] + b[4] * a[16],
		b[5] * a[1] + b[6] * a[5] + b[7] * a[9] + b[8] * a[13],
		b[5] * a[2] + b[6] * a[6] + b[7] * a[10] + b[8] * a[14],
		b[5] * a[3] + b[6] * a[7] + b[7] * a[11] + b[8] * a[15],
		b[5] * a[4] + b[6] * a[8] + b[7] * a[12] + b[8] * a[16],
		b[9] * a[1] + b[10] * a[5] + b[11] * a[9] + b[12] * a[13],
		b[9] * a[2] + b[10] * a[6] + b[11] * a[10] + b[12] * a[14],
		b[9] * a[3] + b[10] * a[7] + b[11] * a[11] + b[12] * a[15],
		b[9] * a[4] + b[10] * a[8] + b[11] * a[12] + b[12] * a[16],
		b[13] * a[1] + b[14] * a[5] + b[15] * a[9] + b[16] * a[13],
		b[13] * a[2] + b[14] * a[6] + b[15] * a[10] + b[16] * a[14],
		b[13] * a[3] + b[14] * a[7] + b[15] * a[11] + b[16] * a[15],
		b[13] * a[4] + b[14] * a[8] + b[15] * a[12] + b[16] * a[16]

	return self
end

function mat4x4:multiply_point(x, y, z)
	local w = self[13] * x + self[14] * y + self[15] * z + self[16]
	return (x * self[1] + y * self[2] + z * self[3] + self[4]),
		(x * self[5] + y * self[6] + z * self[7] + self[8]),
		(x * self[9] + y * self[10] + z * self[11] + self[12]),
		w
end

function mat4x4:multiply_dir(x, y, z)
	local w = self[13] * x + self[14] * y + self[15] * z + self[16]
	return (x * self[1] + y * self[2] + z * self[3]),
		(x * self[5] + y * self[6] + z * self[7]),
		(x * self[9] + y * self[10] + z * self[11]),
		w
end

local tm4 = {}
function mat4x4:inverse()
	local a   = self
	tm4[1]    = a[6] * a[11] * a[16] - a[6] * a[12] * a[15] - a[10] * a[7] * a[16] + a[10] * a[8] * a[15] +
		a[14] * a[7] * a[12] - a[14] * a[8] * a[11]
	tm4[2]    = -a[2] * a[11] * a[16] + a[2] * a[12] * a[15] + a[10] * a[3] * a[16] - a[10] * a[4] * a[15] -
		a[14] * a[3] * a[12] + a[14] * a[4] * a[11]
	tm4[3]    = a[2] * a[7] * a[16] - a[2] * a[8] * a[15] - a[6] * a[3] * a[16] + a[6] * a[4] * a[15] +
		a[14] * a[3] * a[8] - a[14] * a[4] * a[7]
	tm4[4]    = -a[2] * a[7] * a[12] + a[2] * a[8] * a[11] + a[6] * a[3] * a[12] - a[6] * a[4] * a[11] -
		a[10] * a[3] * a[8] + a[10] * a[4] * a[7]
	tm4[5]    = -a[5] * a[11] * a[16] + a[5] * a[12] * a[15] + a[9] * a[7] * a[16] - a[9] * a[8] * a[15] -
		a[13] * a[7] * a[12] + a[13] * a[8] * a[11]
	tm4[6]    = a[1] * a[11] * a[16] - a[1] * a[12] * a[15] - a[9] * a[3] * a[16] + a[9] * a[4] * a[15] +
		a[13] * a[3] * a[12] - a[13] * a[4] * a[11]
	tm4[7]    = -a[1] * a[7] * a[16] + a[1] * a[8] * a[15] + a[5] * a[3] * a[16] - a[5] * a[4] * a[15] -
		a[13] * a[3] * a[8] + a[13] * a[4] * a[7]
	tm4[8]    = a[1] * a[7] * a[12] - a[1] * a[8] * a[11] - a[5] * a[3] * a[12] + a[5] * a[4] * a[11] +
		a[9] * a[3] * a[8] - a[9] * a[4] * a[7]
	tm4[9]    = a[5] * a[10] * a[16] - a[5] * a[12] * a[14] - a[9] * a[6] * a[16] + a[9] * a[8] * a[14] +
		a[13] * a[6] * a[12] - a[13] * a[8] * a[10]
	tm4[10]   = -a[1] * a[10] * a[16] + a[1] * a[12] * a[14] + a[9] * a[2] * a[16] - a[9] * a[4] * a[14] -
		a[13] * a[2] * a[12] + a[13] * a[4] * a[10]
	tm4[11]   = a[1] * a[6] * a[16] - a[1] * a[8] * a[14] - a[5] * a[2] * a[16] + a[5] * a[4] * a[14] +
		a[13] * a[2] * a[8] - a[13] * a[4] * a[6]
	tm4[12]   = -a[1] * a[6] * a[12] + a[1] * a[8] * a[10] + a[5] * a[2] * a[12] - a[5] * a[4] * a[10] -
		a[9] * a[2] * a[8] + a[9] * a[4] * a[6]
	tm4[13]   = -a[5] * a[10] * a[15] + a[5] * a[11] * a[14] + a[9] * a[6] * a[15] - a[9] * a[7] * a[14] -
		a[13] * a[6] * a[11] + a[13] * a[7] * a[10]
	tm4[14]   = a[1] * a[10] * a[15] - a[1] * a[11] * a[14] - a[9] * a[2] * a[15] + a[9] * a[3] * a[14] +
		a[13] * a[2] * a[11] - a[13] * a[3] * a[10]
	tm4[15]   = -a[1] * a[6] * a[15] + a[1] * a[7] * a[14] + a[5] * a[2] * a[15] - a[5] * a[3] * a[14] -
		a[13] * a[2] * a[7] + a[13] * a[3] * a[6]
	tm4[16]   = a[1] * a[6] * a[11] - a[1] * a[7] * a[10] - a[5] * a[2] * a[11] + a[5] * a[3] * a[10] +
		a[9] * a[2] * a[7] - a[9] * a[3] * a[6]

	local det = a[1] * tm4[1] + a[2] * tm4[5] + a[3] * tm4[9] + a[4] * tm4[13]

	if det == 0 then return a end

	det = 1 / det

	for i = 1, 16 do
		self[i] = tm4[i] * det
	end

	return self
end

function mat4x4:tostring()
	return ("%+7.3f"):rep(4, " "):rep(4, "\n"):format(unpack(self))
end

-- local ta = mat4x4:new()
-- local tb = mat4x4:new()
-- for i=1,16 do
-- 	ta[i] = math.random()
-- 	tb[i] = math.random()
-- end

-- print("A=")
-- print(ta:tostring())
-- print("B=")
-- print(tb:tostring())
-- print("A*B=")
-- print(ta:multiply(tb):tostring())
-- print()

return mat4x4
