--- calculates the distance between 2 3d points. If <3 values are passed, it will calculate
--- the distance from 0,0,0. If numbers are nil, that dimension is ignored
---@param x1 number|nil
---@param y1 number|nil
---@param z1 number|nil
---@param x2 number|nil
---@param y2 number|nil
---@param z2 number|nil
---@return number distance
return function(x1, y1, z1, x2, y2, z2)
	x1, y1, z1 = x1 or 0, y1 or 0, z1 or 0
	local dx, dy, dz = x1, y1, z1
	if x2 or y2 or z2 then
		x2, y2, z2 = x2 or x1, y2 or y1, z2 or z1
		dx, dy, dz = x1 - x2, y1 - y2, z1 - z2
	end
	return (dx * dx + dy * dy + dz * dz) ^ .5
end
