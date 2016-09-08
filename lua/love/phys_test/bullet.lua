local Bullet = {
  type = 'bullet'
}
Bullet.__index = Bullet

local function createBody(world, x, y, vx, vy)
  local body = love.physics.newBody(world, x, y, 'dynamic')
  love.physics.newFixture(body, love.physics.newCircleShape(3))
  body:setLinearVelocity(vx, vy)
  body:setUserData(Bullet.new(body))
  return body
end

local function fire(world, source)
  local x, y = source:getPosition()
  x = x + math.cos(source:getAngle()) * 25
  y = y + math.sin(source:getAngle()) * 25
  local vx, vy = source:getLinearVelocity()
  vx = vx + math.cos(source:getAngle()) * 500
  vy = vy + math.sin(source:getAngle()) * 500
  return createBody(world, x, y, vx, vy)
end

function Bullet.new(body)
  local self = setmetatable({}, Bullet)
  self.body = body
  return self
end

return {
  fire = fire
}
