---@param t number
---@param a number
---@param b number
---@param ... number
---@return number ...
local function lerp(t, a, b, ...)
	if not a then return end
	return (1 - t) * a + b * t, lerp(t, ...)
end

return lerp