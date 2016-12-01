local bullet = require('bullet')

local Rocket = {
  type = 'rocket'
}
Rocket.__index = Rocket

local function createBody(world, x, y)
  local body = love.physics.newBody(world, x, y, "dynamic")
  love.physics.newFixture(body, love.physics.newPolygonShape(20, 0, 0, -10, 0, 10))
  body:setUserData(Rocket.new(body))
  body:setFixedRotation(true)
  body:setUserData(Rocket.new(body))
  return body
end

function Rocket.new(body)
  local self = setmetatable({}, Rocket)
  self.body = body
  return self
end

function Rocket:fire()
  local body = self.body
  local world = body:getWorld()
  bullet.fire(world, body)
end

function Rocket:draw()
  local body = self.body
  local fixture = (body:getFixtureList())[1]
  local shape = fixture:getShape()

  love.graphics.setColor(0,0,0,255)
  love.graphics.polygon('fill', body:getWorldPoints(shape:getPoints()))
  love.graphics.setColor(255,255,255,255)
  love.graphics.polygon('line', body:getWorldPoints(shape:getPoints()))
end

return {
  createBody = createBody
}
