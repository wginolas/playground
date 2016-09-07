local mymath = require('mymath')

local Stars = {}
Stars.__index = Stars

function Stars.new(rad)
  local self = setmetatable({}, Stars)
  local i
  local stars = {}

  for i = 1, 1000 do
    table.insert(stars, {
                   x = love.math.random(-rad, rad),
                   y = love.math.random(-rad, rad),
                   s = mymath.rnd(0.5, 1)
    })
  end

  self.stars = stars
  self.rad = rad
  return self
end

function Stars:draw()
  local i, s
  for i, s in ipairs(self.stars) do
    love.graphics.circle("fill", s.x, s.y, 1)
  end
end

function Stars:update(dx, dy)
  local rad = self.rad
  local w, h = love.graphics.getDimensions()
  local i, s
  for i, s in ipairs(self.stars) do
    local x, y, scale = s.x, s.y, s.s
    x = x + dx*scale
    y = y + dy*scale
    if x > rad then
      x = x - rad*2
    end
    if x < -rad then
      x = x + rad*2
    end
    if y > rad then
      y = y - rad*2
    end
    if y < -rad then
      y = y + rad*2
    end
    s.x = x
    s.y = y
  end
end

return {
  Stars = Stars
}
