local length = require "love-math.length2d"

local function normalize(dx, dy)
	local len = length(dx, dy)
	if len > 0 then
		return dx / len, dy / len
	end
	return 0, 0
end

return normalize