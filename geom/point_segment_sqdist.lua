return function(x, y, x1, y1, x2, y2)
	local A = x - x1;
	local B = y - y1;
	local C = x2 - x1;
	local D = y2 - y1;

	local dot = A * C + B * D;
	local len_sq = C * C + D * D;
	local param = -1;
	if len_sq ~= 0 then
		param = dot / len_sq;
	end

	local xx, yy;

	if param < 0 then
		xx = x1;
		yy = y1;
	elseif param > 1 then
		xx = x2;
		yy = y2;
	else
		xx = x1 + param * C;
		yy = y1 + param * D;
	end

	local dx = x - xx;
	local dy = y - yy;
	return dx * dx + dy * dy;
end
