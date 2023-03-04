---@param radius number
---@param sphere_x number
---@param sphere_y number
---@param sphere_z number
---@param ray_ox number
---@param ray_oy number
---@param ray_oz number
---@param ray_dx number
---@param ray_dy number
---@param ray_dz number
---@return number|nil hit_x
---@return number|nil hit_y
---@return number|nil hit_z
---@return number|nil distance
return function(ray_ox, ray_oy, ray_oz, ray_dx, ray_dy, ray_dz, radius, sphere_x, sphere_y, sphere_z)
	local oc_x, oc_y, oc_z =
		ray_ox - sphere_x,
		ray_oy - sphere_y,
		ray_oz - sphere_z

	local b = ray_dx * oc_x + ray_dy * oc_y + ray_dz * oc_z
	local c = oc_x * oc_x + oc_y * oc_y + oc_z * oc_z - radius * radius
	if c > 0 and b > 0 then
		return
	end

	local discriminant = b * b - c
	if discriminant < 0 then
		return
	end

	local t = -b - discriminant ^ .5

	if t < 0 then
		return
	end

	return ray_ox + t * ray_dx,
		ray_oy + t * ray_dy,
		ray_oz + t * ray_dz, t
end
