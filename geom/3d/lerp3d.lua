return function(t, x1, y1, z1, x2, y2, z2)
	local u = 1 - t
	return
		x1 * u + x2 * t,
		y1 * u + y2 * t,
		z1 * u + z2 * t
end
