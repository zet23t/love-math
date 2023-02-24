---returns minimal differance between radian values a and b 
---@param a number
---@param b number
---@return number
return function (a,b)
	local d = a - b
	if d > math.pi then
		d = d - math.pi * 2
	elseif d < -math.pi then
		d = d + math.pi * 2
	end
	return d
end