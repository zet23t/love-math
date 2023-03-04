return function(x, y, z)
	local d = x * x + y * y + z * z
	if d == 0 then return 0, 0, 0, 0 end
	d = d ^ .5
	return x / d, y / d, z / d, d
end
