local mymath = require('mymath')
local asteroid = require('asteroid')
local stars = require('stars')
local rocket = require('rocket')

debug = true
local ASTER_COUNT = 50
local ASTER_SPEED = 100
local ASTER_SIZE = 50

local toSplit = {}

local t = 0

local function collidePostSolve(fixture1, fixture2, contact)
  --print(fixture1, fixture2, contact)
  local fixtures = {fixture1, fixture2}
  for i, f in ipairs(fixtures) do
    local other = fixtures[3-i]
    if f:getBody():getUserData().type == 'bullet' then
      print('peng')
      f:getBody():destroy()
      table.insert(toSplit, other:getBody())
    end
  end
end

function love.load()
  print(_VERSION)
  local w, h = love.graphics.getDimensions()
  MAX_PX = math.sqrt(w*w + h*h) / 2
  world = love.physics.newWorld(0, 0, 800, 600, 0, 0)
  world:setCallbacks(null, null, null, collidePostSolve)
  rocket = rocket.createBody(world, 0, 0)
  stars = stars.Stars.new(MAX_PX)
end

function love.draw()
  local w, h = love.graphics.getDimensions()
  love.graphics.push()
  love.graphics.translate(w/2, h/2)
  love.graphics.rotate(-rocket:getAngle() - math.pi/2)
  stars:draw()
  love.graphics.translate(-rocket:getX(), -rocket:getY())

  for i, b in ipairs(world:getBodyList()) do
    b:getUserData():draw()
  end

  love.graphics.pop()
end

function love.keypressed(key, scancode, isrepeat)
  if not isrepeat then
    if key == 'space' or key == 'lctrl' then
      rocket:getUserData():fire()
    end
  end
end

local function updateAsteroids()
  local count = 0
  local rOuter, rInner = MAX_PX*2, MAX_PX

  local i,b
  for i, b in ipairs(world:getBodyList()) do
    local type = b:getUserData().type
    if type == 'aster' then
      if mymath.dist(rocket:getX(), rocket:getY(), b:getX(), b:getY()) > rOuter then
        b:destroy()
      else
        count = count + 1
      end
    end
    if type == 'bullet' then
      if mymath.dist(rocket:getX(), rocket:getY(), b:getX(), b:getY()) > rOuter then
        b:destroy()
      end
    end
  end

  if count < ASTER_COUNT then
    local x, y = mymath.randomPointInCircle(rOuter, rInner)
    local vx, vy = mymath.randomPointInCircle(ASTER_SPEED, 0)
    local va = mymath.rnd(-2, 2)
    local a = mymath.rnd(0, 2*math.pi)
    local r = love.math.random(ASTER_SIZE)
    x = x + rocket:getX()
    y = y + rocket:getY()
    asteroid.createBody(world, x, y, a, vx, vy, va, asteroid.createShape(r))
  end
end

function splitAsteroids()
  local i, b
  for i, a in ipairs(toSplit) do
    a:getUserData():split()
  end
  toSplit = {}
end

function love.update(dt)
  if love.keyboard.isDown('up') then
    rocket:applyForce(rocket:getWorldVector(30, 0))
  end

  rocket:setAngularVelocity(0)

  if love.keyboard.isDown('left') then
    --rocket:applyTorque(-10)
    rocket:setAngularVelocity(-2)
  end

  if love.keyboard.isDown('right') then
    --rocket:applyTorque(10)
    rocket:setAngularVelocity(2)
  end

  local rx1, ry1 = rocket:getPosition()
  world:update(dt)
  local rx2, ry2 = rocket:getPosition()
  stars:update(rx1 - rx2, ry1 - ry2)

  splitAsteroids()
  updateAsteroids()

  t = t + dt
end
