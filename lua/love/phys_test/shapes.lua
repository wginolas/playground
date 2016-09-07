local mymath = require('mymath')

local function randomPolygonShape(rOuter)
  local i, ps, shape

  ps = {}
  for i = 1, 8 do
    local x, y = mymath.randomPointInCircle(rOuter, 0)
    table.insert(ps, x)
    table.insert(ps, y)
    if i >= 3 then
      local s = love.physics.newPolygonShape(ps)
      if s:validate() then
        shape = s
      end
    end
  end
  return shape
end

local function splitShape(s)
  local result = {}
  local p = {s:getPoints()}
  local len = #p / 2
  local cx, cy = 0, 0

  local i
  -- find center
  for i = 1, len do
    cx = cx + p[i*2-1]
    cy = cy + p[i*2]
  end
  cx = cx / len
  cy = cy / len

  -- split into triangles
  local x1 = p[len*2-1]
  local y1 = p[len*2]
  for i = 1, len do
    local x2 = p[i*2-1]
    local y2 = p[i*2]
    table.insert(result, love.physics.newPolygonShape(cx, cy, x1, y1, x2, y2))
    x1, y1 = x2, y2
  end

  return result
end

return {
  randomPolygonShape = randomPolygonShape,
  splitShape = splitShape
}
