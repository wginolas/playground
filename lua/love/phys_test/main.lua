debug = true
ASTER_COUNT = 50
ASTER_SPEED = 100
ASTER_SIZE = 50

toSplit = {}

t = 0

function dist(x1, y1, x2, y2)
  local dx, dy = x2 - x1, y2 - y1
  return math.sqrt(dx*dx + dy*dy)
end

function rnd(min, max)
  return love.math.random() * (max - min) + min
end

function randomPointInCircle(rOuter, rInner)
  local x, y, d
  repeat
    x, y = rnd(-rOuter, rOuter), rnd(-rOuter, rOuter)
    d = dist(0, 0, x, y)
  until d<=rOuter and d>=rInner
  return x, y
end

function randomPolygonShape(rOuter, rand)
  local i, ps, shape

  ps = {}
  for i = 1, 8 do
    local x, y = randomPointInCircle(rOuter, 0)
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

function splitShape(s)
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

function splitAster(world, body)
  local fixture = (body:getFixtureList())[1]
  local shape = fixture:getShape()

  local bodies = {}
  local shapes = splitShape(shape)
  local i, s
  for i, s in ipairs(shapes) do
    local centerX, centerY, mass, inertia = s:computeMass(1)
    if mass>0.05 then
      local b = love.physics.newBody(world, body:getX(), body:getY(), "dynamic")
      b:setLinearVelocity(body:getLinearVelocity())
      b:setAngularVelocity(body:getAngularVelocity())
      b:setAngle(body:getAngle())
      local fixture = love.physics.newFixture(b, s)
      fixture:setFriction(0.9)
      fixture:setRestitution(0.5)
      b:setUserData({type='aster'})
      table.insert(bodies, b)
    end
  end
  body:destroy()
  return bodies
end

function createAster(world, x, y, vx, vy, va, r)
  local body = love.physics.newBody(world, x, y, "dynamic")
  local shape = randomPolygonShape(r, r/100)
  local fixture = love.physics.newFixture(body, shape)
  fixture:setFriction(0.9)
  fixture:setRestitution(0.5)
  body:setLinearVelocity(vx, vy)
  body:setAngularVelocity(va)
  body:setUserData({type='aster'})
  return body
end

function createOuterBox(world, x1, y1, x2, y2)
  local body = love.physics.newBody(world, 0, 0, "static")
  love.physics.newFixture(body, love.physics.newEdgeShape(x1, y1, x1, y2))
  love.physics.newFixture(body, love.physics.newEdgeShape(x1, y2, x2, y2))
  love.physics.newFixture(body, love.physics.newEdgeShape(x2, y2, x2, y1))
  love.physics.newFixture(body, love.physics.newEdgeShape(x2, y1, x1, y1))
  return body
end

function createBullet(world, x, y, dx, dy)
  local body = love.physics.newBody(world, x, y, 'dynamic')
  love.physics.newFixture(body, love.physics.newCircleShape(3))
  body:setLinearVelocity(dx, dy)
  body:setUserData({type='bullet'})
  return body
end

function fireBullet()
  local x, y = rocket:getPosition()
  x = x + math.cos(rocket:getAngle()) * 25
  y = y + math.sin(rocket:getAngle()) * 25
  local dx, dy = rocket:getLinearVelocity()
  dx = dx + math.cos(rocket:getAngle()) * 500
  dy = dy + math.sin(rocket:getAngle()) * 500
  createBullet(world, x, y, dx, dy)
end

function createStars()
  local i
  local stars = {}

  for i = 1, 1000 do
    table.insert(stars, {
                   x = love.math.random(-MAX_PX, MAX_PX),
                   y = love.math.random(-MAX_PX, MAX_PX),
                   s = love.math.random() / 2 + 0.5
    })
  end
  return stars
end

function drawStars(stars)
  local i, s
  for i, s in ipairs(stars) do
    love.graphics.circle("fill", s.x, s.y, 1)
  end
end

function updateStars(stars, dx, dy)
  local i, s
  local w, h = love.graphics.getDimensions()
  for i, s in ipairs(stars) do
    local x, y, scale = s.x, s.y, s.s
    x = x + dx*scale
    y = y + dy*scale
    if x > MAX_PX then
      x = x - MAX_PX*2
    end
    if x < -MAX_PX then
      x = x + MAX_PX*2
    end
    if y > MAX_PX then
      y = y - MAX_PX*2
    end
    if y < -MAX_PX then
      y = y + MAX_PX*2
    end
    s.x = x
    s.y = y
  end
end

function createRocket(world, x, y)
  local body = love.physics.newBody(world, x, y, "dynamic")
  love.physics.newFixture(body, love.physics.newPolygonShape(20, 0, 0, -10, 0, 10))
  body:setUserData({type='rocket'})
  body:setFixedRotation(true)
  return body
end

function collidePostSolve(fixture1, fixture2, contact)
  --print(fixture1, fixture2, contact)
  local i, f
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
  rocket = createRocket(world, 400, 300)
  stars = createStars()
end

function love.draw()
  local i, b, j, f

  local w, h = love.graphics.getDimensions()
  love.graphics.push()
  love.graphics.translate(w/2, h/2)
  love.graphics.rotate(-rocket:getAngle() - math.pi/2)
  drawStars(stars)
  love.graphics.translate(-rocket:getX(), -rocket:getY())

  for i, b in ipairs(world:getBodyList()) do
    for j, f in ipairs(b:getFixtureList()) do
      local s = f:getShape()
      if s:getType() == 'circle' then
        love.graphics.circle("fill", b:getX(), b:getY(), f:getShape():getRadius())
      end
      if s:getType() == 'polygon' then
        love.graphics.setColor(0,0,0,255)
        love.graphics.polygon('fill', b:getWorldPoints(s:getPoints()))
        love.graphics.setColor(255,255,255,255)
        love.graphics.polygon('line', b:getWorldPoints(s:getPoints()))
      end
    end
  end

  love.graphics.pop()
end

function love.keypressed(key, scancode, isrepeat)
  if not isrepeat then
    if key == 'space' then
      fireBullet()
    end
  end
end

function updateAsteroids()
  local count = 0
  local rOuter, rInner = MAX_PX*2, MAX_PX

  local i,b
  for i, b in ipairs(world:getBodyList()) do
    local type = b:getUserData().type
    if type == 'aster' then
      if dist(rocket:getX(), rocket:getY(), b:getX(), b:getY()) > rOuter then
        b:destroy()
      else
        count = count + 1
      end
    end
    if type == 'bullet' then
      if dist(rocket:getX(), rocket:getY(), b:getX(), b:getY()) > rOuter then
        b:destroy()
      end
    end
  end

  if count < ASTER_COUNT then
    local x, y = randomPointInCircle(rOuter, rInner)
    local vx, vy = randomPointInCircle(ASTER_SPEED, 0)
    local va = love.math.random() * 4 - 2
    local r = love.math.random(ASTER_SIZE)
    x = x + rocket:getX()
    y = y + rocket:getY()
    createAster(world, x, y, vx, vy, va, r)
  end
end

function splitAsteroids()
  local i, b
  for i, a in ipairs(toSplit) do
    splitAster(world, a)
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
  updateStars(stars, rx1 - rx2, ry1 - ry2)

  splitAsteroids()
  updateAsteroids()

  t = t + dt
end
