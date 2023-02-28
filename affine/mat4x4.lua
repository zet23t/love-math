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

function mat4x4:get_row_z(s)
	s = s or 1
	return self[9] * s, self[10] * s, self[11] * s
end

function mat4x4:get_position(s)
	s = s or 1
	return self[4] * s, self[8] * s, self[12] * s
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

function mat4x4:scale(x, y, z)
	self[1], self[2], self[3], self[4],
	self[5], self[6], self[7], self[8],
	self[9], self[10], self[11], self[12] =
		self[1] * x, self[2] * x, self[3] * x, self[4] * x,
		self[5] * y, self[6] * y, self[7] * y, self[8] * y,
		self[9] * z, self[10] * z, self[11] * z, self[12] * z
	return self
end

function mat4x4:set_y_rot(radians)
	local s, c = math.sin(radians), math.cos(radians)
	self[1], self[3] = s, -c
	self[9], self[11] = c, s
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
    local top = near * math.tan(fov *math.pi / 180 /2)
    local bottom = -1*top
    local right = top * aspect
    local left = -1*right

    self[1],  self[2],  self[3],  self[4]  = 2*near/(right-left), 0, (right+left)/(right-left), 0
    self[5],  self[6],  self[7],  self[8]  = 0, 2*near/(top-bottom), (top+bottom)/(top-bottom), 0
    self[9],  self[10], self[11], self[12] = 0, 0, -1*(far+near)/(far-near), -2*far*near/(far-near)
    self[13], self[14], self[15], self[16] = 0, 0, -1, 0
	return self
end

function mat4x4:multiply(m)
	local
	s11, s12, s13, s14,
	s21, s22, s23, s24,
	s31, s32, s33, s34,
	s41, s42, s43, s44 = unpack(self)
	local
	m11, m12, m13, m14,
	m21, m22, m23, m24,
	m31, m32, m33, m34,
	m41, m42, m43, m44 = unpack(m)

	self[1], self[2], self[3], self[4],
	self[5], self[6], self[7], self[8],
	self[9], self[10], self[11], self[12],
	self[13], self[14], self[15], self[16] =
		s11 * m11 + s12 * m21 + s13 * m31 + s14 * m41,
		s11 * m12 + s12 * m22 + s13 * m32 + s14 * m42,
		s11 * m13 + s12 * m23 + s13 * m33 + s14 * m43,
		s11 * m14 + s12 * m24 + s13 * m34 + s14 * m44,

		s21 * m11 + s22 * m21 + s23 * m31 + s24 * m41,
		s21 * m12 + s22 * m22 + s23 * m32 + s24 * m42,
		s21 * m13 + s22 * m23 + s23 * m33 + s24 * m43,
		s21 * m14 + s22 * m24 + s23 * m34 + s24 * m44,

		s31 * m11 + s32 * m21 + s33 * m31 + s34 * m41,
		s31 * m12 + s32 * m22 + s33 * m32 + s34 * m42,
		s31 * m13 + s32 * m23 + s33 * m33 + s34 * m43,
		s31 * m14 + s32 * m24 + s33 * m34 + s34 * m44,

		s41 * m11 + s42 * m21 + s43 * m31 + s44 * m41,
		s41 * m12 + s42 * m22 + s43 * m32 + s44 * m42,
		s41 * m13 + s42 * m23 + s43 * m33 + s44 * m43,
		s41 * m14 + s42 * m24 + s43 * m34 + s44 * m44

	return self
end

function mat4x4:multiply_left(m)
	local
	s11, s12, s13, s14,
	s21, s22, s23, s24,
	s31, s32, s33, s34,
	s41, s42, s43, s44 = unpack(m)
	local
	m11, m12, m13, m14,
	m21, m22, m23, m24,
	m31, m32, m33, m34,
	m41, m42, m43, m44 = unpack(self)

	self[1], self[2], self[3], self[4],
	self[5], self[6], self[7], self[8],
	self[9], self[10], self[11], self[12],
	self[13], self[14], self[15], self[16] =
		s11 * m11 + s12 * m21 + s13 * m31 + s14 * m41,
		s11 * m12 + s12 * m22 + s13 * m32 + s14 * m42,
		s11 * m13 + s12 * m23 + s13 * m33 + s14 * m43,
		s11 * m14 + s12 * m24 + s13 * m34 + s14 * m44,

		s21 * m11 + s22 * m21 + s23 * m31 + s24 * m41,
		s21 * m12 + s22 * m22 + s23 * m32 + s24 * m42,
		s21 * m13 + s22 * m23 + s23 * m33 + s24 * m43,
		s21 * m14 + s22 * m24 + s23 * m34 + s24 * m44,

		s31 * m11 + s32 * m21 + s33 * m31 + s34 * m41,
		s31 * m12 + s32 * m22 + s33 * m32 + s34 * m42,
		s31 * m13 + s32 * m23 + s33 * m33 + s34 * m43,
		s31 * m14 + s32 * m24 + s33 * m34 + s34 * m44,

		s41 * m11 + s42 * m21 + s43 * m31 + s44 * m41,
		s41 * m12 + s42 * m22 + s43 * m32 + s44 * m42,
		s41 * m13 + s42 * m23 + s43 * m33 + s44 * m43,
		s41 * m14 + s42 * m24 + s43 * m34 + s44 * m44

	return self
end

function mat4x4:multiply_point(x,y,z)
	local w = self[13] * x + self[14] * y + self[15] * z + self[16]
	return (x * self[1] + y * self[4] + z * self[3] + self[4]),
		(x * self[5] + y * self[6] + z * self[7] + self[8]),
		(x * self[9] + y * self[10] + z * self[11] + self[12]),
		w
end

function mat4x4:tostring()
	return ("%+.3f"):rep(4, " "):rep(4, "\n"):format(unpack(self))
end

return mat4x4
