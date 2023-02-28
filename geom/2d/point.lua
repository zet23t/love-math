--[[
Copyright (c) 2010-2011 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

History:
 - 2023-02-26: Imported & modified from https://github.com/TannerRogalsky/Stratcave
]]

local sqrt, cos, sin = math.sqrt, math.cos, math.sin

---@class point
local point = setmetatable({}, {__call = function(t,...) return t:new(...) end})
point.__index = point

function point:new(x, y)
	return setmetatable({ x = x or 0, y = y or 0 }, self)
end

function point:initialize(x, y)
	self.x = x
	self.y = y
end

function point:clone()
	return point:new(self.x, self.y)
end

function point:unpack()
	return self.x, self.y
end

function point:__tostring()
	return "(" .. tonumber(self.x) .. "," .. tonumber(self.y) .. ")"
end

function point.__unm(a)
	return point( -a.x, -a.y)
end

function point.__add(a, b)
	return point(a.x + b.x, a.y + b.y)
end

function point.__sub(a, b)
	return point(a.x - b.x, a.y - b.y)
end

function point.__mul(a, b)
	if type(a) == "number" then
		return point(a * b.x, a * b.y)
	elseif type(b) == "number" then
		return point(b * a.x, b * a.y)
	else
		return a.x * b.x + a.y * b.y
	end
end

function point.__div(a, b)
	return point(a.x / b, a.y / b)
end

function point.__eq(a, b)
	return a.x == b.x and a.y == b.y
end

function point.__lt(a, b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function point.__le(a, b)
	return a.x <= b.x and a.y <= b.y
end

function point.permul(a, b)
	return point(a.x * b.x, a.y * b.y)
end

function point:len2()
	return self.x * self.x + self.y * self.y
end

function point:len()
	return (self.x * self.x + self.y * self.y) ^ 0.5
end

function point.dist(a, b)
	local dx, dy = a.x - b.x, a.y - b.y
	return (dx * dx + dy * dy) ^ .5
end

function point:normalize_inplace()
	local l = self:len()
	if l > 0 then
		self.x, self.y = self.x / l, self.y / l
	end
	return self
end

function point:normalized()
	return self / self:len()
end

function point:rotate_inplace(phi)
	local c, s = cos(phi), sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	return self
end

function point:rotated(phi)
	return self:clone():rotate_inplace(phi)
end

function point:perpendicular()
	return point( -self.y, self.x)
end

function point:project_on(v)
	return (self * v) * v / v:len2()
end

function point:cross(other)
	return self.x * other.y - self.y * other.x
end

return point
