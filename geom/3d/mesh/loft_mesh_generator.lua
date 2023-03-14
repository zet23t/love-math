local mat4x4 = require "love-math.affine.mat4x4"

---@class loft_mesh_generator : object
local loft_mesh_generator = require "love-util.class" "loft_mesh_generator"
function loft_mesh_generator:new()
	return self:create {
		path = {},

	}
end


return loft_mesh_generator
