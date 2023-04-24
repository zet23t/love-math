---@param min number
---@param max number
---@param v number
---@param ... number
---@return number ...
local function invlerp(min, max, v, ...)
	if not v then return end
	local t = (v - min) / (max - min)
	return t, invlerp(t, ...)
end

return invlerp