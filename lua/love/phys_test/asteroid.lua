local shapes = require('shapes')

local Asteroid = {
  type = 'aster'
}
Asteroid.__index = Asteroid

local function createBody(world, x, y, a, vx, vy, va, shape)
  local body = love.physics.newBody(world, x, y, "dynamic")
  local fixture = love.physics.newFixture(body, shape)
  fixture:setFriction(0.9)
  fixture:setRestitution(0.5)
  body:setAngle(a)
  body:setLinearVelocity(vx, vy)
  body:setAngularVelocity(va)
  body:setUserData(Asteroid.new(body))
  return body
end

function Asteroid.new(body)
  local self = setmetatable({}, Asteroid)
  self.body = body
  return self
end

function Asteroid:split()
  local body = self.body
  local world = body:getWorld()
  local fixture = (body:getFixtureList())[1]
  local shape = fixture:getShape()

  local bodies = {}
  for i, s in ipairs(shapes.splitShape(shape)) do
    local centerX, centerY, mass, inertia = s:computeMass(1)
    if mass>0.05 then
      local vx, vy = body:getLinearVelocity()
      local b = createBody(world, body:getX(), body:getY(), body:getAngle(), vx, vy, body:getAngularVelocity(), s)
      table.insert(bodies, b)
    end
  end
  body:destroy()
  return bodies
end

function Asteroid:draw()
  local body = self.body
  local fixture = (body:getFixtureList())[1]
  local shape = fixture:getShape()

  love.graphics.setColor(0,0,0,255)
  love.graphics.polygon('fill', body:getWorldPoints(shape:getPoints()))
  love.graphics.setColor(255,255,255,255)
  love.graphics.polygon('line', body:getWorldPoints(shape:getPoints()))
end

local function createShape(r)
  return shapes.randomPolygonShape(r)
end

return {
  createBody = createBody,
  createShape = createShape
}
