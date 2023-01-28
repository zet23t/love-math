---returns true for each pair of x,y coordinates passed if it is inside the rect
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param px number
---@param py number
---@param ... unknown
---@return ... boolean
local function rect_contains(x1,y1,x2,y2,px,py,...)
	if px then
		local is_inside = px >= x1 and py >= y1 and px < x2 and py < y2
		return is_inside, rect_contains(x1,y1,x2,y2,...)
	end
end

return rect_contains