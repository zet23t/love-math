---Returns the average of input numbers
---@param x number
---@param ... number
---@return number average
return function (x,...)
	local n = select('#', ...)
	for i=1, n do
		x = x + select(i, ...)
	end
	return x / (n + 1)
end