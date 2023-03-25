return function(x, y, z, x1, y1, z1, x2, y2, z2)
	local dx1 = x - x1
	local dy1 = y - y1
	local dz1 = z - z1
	local dx2 = x2 - x1
	local dy2 = y2 - y1
	local dz2 = z2 - z1

	local dot = dx1 * dx2 + dy1 * dy2 + dz1 * dz2
	local len_sq = dx2 * dx2 + dy2 * dy2 + dz2 * dz2
	local param = -1
	if len_sq == 0 then
		return dx1 * dx1 + dy1 * dy1 + dz1 * dz1, x1, y1, z1
	end

	param = dot / len_sq;

	local xx, yy, zz

	if param <= 0 then
		xx, yy, zz = x1, y1, z1
	elseif param >= 1 then
		xx, yy, zz = x2, y2, z2
	else
		xx = x1 + param * dx2
		yy = y1 + param * dy2
		zz = z1 + param * dz2
	end

	local dx = x - xx
	local dy = y - yy
	local dz = z - zz
	return dx * dx + dy * dy + dz * dz, xx, yy, zz
end
