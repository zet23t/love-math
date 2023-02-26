---@param x number
---@param ... number
---@return integer|nil
local function floor (x, ...)
	if not x then return end
	return math.floor(x), floor(...)
end

return floor