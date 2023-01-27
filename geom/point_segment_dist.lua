local sqd = require "love-math.geom.point_segment_dist"
return function(x, y, x1, y1, x2, y2)
	return sqd(x, y, x1, y1, x2, y2) ^ .5;
end
