local function clamp(min, max, v, ...)
	if v then
		v = (v > max and max) or (v < min and min) or v
		return v, clamp(min, max, ...)
	end
end

return clamp
