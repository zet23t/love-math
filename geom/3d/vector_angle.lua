return function(ox, oy, oz, ax, ay, az, bx, by, bz)
	ax, ay, az = ax - ox, ay - oy, az - oz
	bx, by, bz = bx - ox, by - oy, bz - oz
	local dot = ax * bx + ay * by + az * bz
	local da = (ax * ax + ay * ay + az * az) ^ .5
	local db = (bx * bx + by * by + bz * bz) ^ .5
	return math.acos(dot / (da * db))
end
