--- Modified code from https://2dengine.com/?p=intersections#Segment_vs_segment
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
---@param x4 number
---@param y4 number
---@return boolean is_intersecting
---@return number|nil x optional point of intersection
---@return number|nil y optional point of intersection
local function find_segment_segment_intersection(x1, y1, x2, y2, x3, y3, x4, y4)
  local dx1, dy1 = x2 - x1, y2 - y1
  local dx2, dy2 = x4 - x3, y4 - y3
  local dx3, dy3 = x1 - x3, y1 - y3
  local d = dx1 * dy2 - dy1 * dx2
  if d == 0 then
    return false
  end
  local t1 = (dx2 * dy3 - dy2 * dx3) / d
  if t1 < 0 or t1 > 1 then
    return false
  end
  local t2 = (dx1 * dy3 - dy1 * dx3) / d
  if t2 < 0 or t2 > 1 then
    return false
  end
  -- point of intersection
  return true, x1 + t1 * dx1, y1 + t1 * dy1
end

return find_segment_segment_intersection