---Linear interpolation between angle values - handles flipping (more or less)
---You can pass any number of a/b pairs to get all interpolated values
---@param t number
---@param a number a radians value (should be between -2pi and +2pi)
---@param b number a radians value (should be between -2pi and +2pi)
---@param ... number
---@return number|nil, ...
local function angle_lerp(t, a, b, ...)
	if not a then return end
	local d = b - a
	if d > math.pi then
		d = d - math.pi * 2
	elseif d < -math.pi then
		d = d + math.pi * 2
	end
	b = a + d
	return (1 - t) * a + b * t, angle_lerp(t, ...)
end

return angle_lerp
