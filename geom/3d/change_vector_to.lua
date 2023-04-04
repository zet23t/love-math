return function(max_delta, fx, fy, fz, tx, ty, tz)
	local dx, dy, dz = tx - fx, ty - fy, tz - fz
	local sqd = dx*dx+dy*dy+dz*dz
	if sqd <= max_delta * max_delta then
		return tx,ty,tz
	end
	local dist = max_delta / (sqd ^ .5)
	local nx,ny,nz = dx * dist, dy * dist, dz * dist
	return fx + nx, fy + ny, fz + nz
end
