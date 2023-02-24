local clamp = require "love-math.clamp"
---will return a radians value that moved from "from" to "to" by the amount of max_delta
---@param max_delta number
---@param from number
---@param to number
---@return number
return function (max_delta, from, to)
	local d = to - from
	if d > math.pi then
		d = d - math.pi * 2
	elseif d < -math.pi then
		d = d + math.pi * 2
	end
	return from + clamp(-max_delta, max_delta, d)
end