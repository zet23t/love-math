local length = require "love-math.geom.2d.length2d"

local function normalize(dx, dy)
	local len = length(dx, dy)
	if len > 0 then
		return dx / len, dy / len, len
	end
	return 0, 0, 0
end

return normalize