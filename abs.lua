---@param x number
---@param ... number
---@return integer|nil
local function abs (x, ...)
	if not x then return end
	return math.abs(x), abs(...)
end

return abs