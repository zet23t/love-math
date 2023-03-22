return function(x, y, z, scale)
	local d = x * x + y * y + z * z
	if d == 0 then return 0, 0, 0, 0 end
	d = (d ^ .5) / (scale or 1)
	return x / d, y / d, z / d, d
end
