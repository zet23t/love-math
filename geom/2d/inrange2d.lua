return function(r, dx, dy)
	local d2 = dx * dx + dy * dy
	return d2 <= r * r
end
