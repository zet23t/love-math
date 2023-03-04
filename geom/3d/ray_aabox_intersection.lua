---@param min_x number
---@param min_y number
---@param min_z number
---@param max_x number
---@param max_y number
---@param max_z number
---@param ray_x number
---@param ray_y number
---@param ray_z number
---@param dir_x number
---@param dir_y number
---@param dir_z number
---@return number|nil hit_x
---@return number|nil hit_y
---@return number|nil hit_z
---@return number|nil normal_x
---@return number|nil normal_y
---@return number|nil normal_z
return function (ray_x, ray_y, ray_z, dir_x, dir_y, dir_z, min_x, min_y, min_z, max_x, max_y, max_z)
	local txmin, tymin, tzmin = (min_x - ray_x) / dir_x, (min_y - ray_y) / dir_y, (min_z - ray_z) / dir_z
	local txmax, tymax, tzmax = (max_x - ray_x) / dir_x, (max_y - ray_y) / dir_y, (max_z - ray_z) / dir_z

	if txmin > txmax then txmin, txmax = txmax, txmin end
	if tymin > tymax then tymin, tymax = tymax, tymin end
	if tzmin > tzmax then tzmin, tzmax = tzmax, tzmin end

	local tmin = math.max(txmin, math.max(tymin, tzmin))
	local tmax = math.min(txmax, math.min(tymax, tzmax))

	if tmax < 0 or tmin > tmax then return end

	local hit_x, hit_y, hit_z
	if tmin >= 0 then
		if txmin == tmin then
			-- hit front face
			hit_x, hit_y, hit_z = min_x, ray_y + tmin * dir_y, ray_z + tmin * dir_z
			return hit_x, hit_y, hit_z, -1, 0, 0
		elseif tymin == tmin then
			-- hit bottom face
			hit_x, hit_y, hit_z = ray_x + tmin * dir_x, min_y, ray_z + tmin * dir_z
			return hit_x, hit_y, hit_z, 0, -1, 0
		else
			-- hit left face
			hit_x, hit_y, hit_z = ray_x + tmin * dir_x, ray_y + tmin * dir_y, min_z
			return hit_x, hit_y, hit_z, 0, 0, -1
		end
	else
		if txmax == tmin then
			-- hit back face
			hit_x, hit_y, hit_z = max_x, ray_y + tmin * dir_y, ray_z + tmin * dir_z
			return hit_x, hit_y, hit_z, 1, 0, 0
		elseif tymax == tmin then
			-- hit top face
			hit_x, hit_y, hit_z = ray_x + tmin * dir_x, max_y, ray_z + tmin * dir_z
			return hit_x, hit_y, hit_z, 0, 1, 0
		else
			-- hit right face
			hit_x, hit_y, hit_z = ray_x + tmin * dir_x, ray_y + tmin * dir_y, max_z
			return hit_x, hit_y, hit_z, 0, 0, 1
		end
	end
end
