---@param ray_x number
---@param ray_y number
---@param ray_z number
---@param dir_x number
---@param dir_y number
---@param dir_z number
---@param plane_x number
---@param plane_y number
---@param plane_z number
---@param normal_x number
---@param normal_y number
---@param normal_z number
---@return number|nil x component (or nil when there is no intersection)
---@return number|nil y component
---@return number|nil z component
return function(ray_x, ray_y, ray_z, dir_x, dir_y, dir_z, plane_x, plane_y, plane_z, normal_x, normal_y, normal_z)
	local denominator = normal_x * dir_x + normal_y * dir_y + normal_z * dir_z

	if math.abs(denominator) < 0.0001 then
		return
	end

	local t = ((plane_x - ray_x) * normal_x + (plane_y - ray_y) * normal_y + (plane_z - ray_z) * normal_z) / denominator

	if t < 0 then
		return
	end

	return
		ray_x + t * dir_x,
		ray_y + t * dir_y,
		ray_z + t * dir_z
end
