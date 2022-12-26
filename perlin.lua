local lerp = require "love-math.lerp"

local function perlin(x, y, dims)
	local v, s, m = 0, 1, 0
	for i = 0, dims or 1 do
		local ix, iy = math.floor(x), math.floor(y)
		local sx, sy = x - ix, y - iy
		local a, b, c, d = love.math.noise(ix, iy), love.math.noise(ix + 1, iy), love.math.noise(ix, iy + 1),
			love.math.noise(ix + 1, iy + 1)
		v = v + lerp(sy, lerp(sx, a, b), lerp(sx, c, d)) * s
		m = m + s
		s = s * 0.4
		x = x * 2 + 23.1
		y = y * 2 + 4.532
	end

	return v / m
end

return perlin