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

function randomPointInCircle(rOuter, rInner)
  local x, y, d
  repeat
    x, y = love.math.random(-rOuter, rOuter), love.math.random(-rOuter, rOuter)
    d = dist(0, 0, x, y)
  until d<=rOuter and d>=rInner
  return x, y
end

function randomPolygonShape(rOuter, rand)
  local i, ps, shape

  repeat
    ps = {}
    for i = 1, 8 do
      local x = math.cos(i/4 * math.pi) * rOuter
      local y = math.sin(i/4 * math.pi) * rOuter
      table.insert(ps, x)
      table.insert(ps, y)
    end
    shape = love.physics.newPolygonShape(ps)
    return shape
  until shape:validate()
  return shape
end

function splitShape(s)
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


end

function splitShapeOld(s)
  local p = {s:getPoints()}
  local newX = (p[1] + p[#p-1]) / 2
  local newY = (p[2] + p[#p]) / 2
  table.insert(p, 1, newY)
  table.insert(p, 1, newX)
  local len = #p / 2
  local halfLen = math.floor(len / 2) + 1
  local p1 = {}
  local p2 = {}
  local i
  for i = 1, len do
    local x = p[i*2-1]
    local y = p[i*2]
    if i <= halfLen then
      print(i, 1)
      table.insert(p1, x)
      table.insert(p1, y)
    end
    if i >= halfLen then
      print(i, 2)
      table.insert(p2, x)
      table.insert(p2, y)
    end
  end
  table.insert(p2, p[1])
  table.insert(p2, p[2])
  return love.physics.newPolygonShape(p1), love.physics.newPolygonShape(p2)
end

function splitAster(world, body)
  local fixture = (body:getFixtureList())[1]
  local shape = fixture:getShape()

  local bodies = {love.physics.newBody(world, body:getX(), body:getY(), "dynamic"),
                  love.physics.newBody(world, body:getX(), body:getY(), "dynamic")}
  local shapes = {splitShape(shape)}
  local i, b
  for i, b in ipairs(bodies) do
    b:setLinearVelocity(body:getLinearVelocity())
    b:setAngularVelocity(body:getAngularVelocity())
    b:setAngle(body:getAngle())
    local fixture = love.physics.newFixture(b, shapes[i])
    fixture:setFriction(0.9)
    fixture:setRestitution(0.5)
    b:setUserData({type='aster'})
  end
  body:destroy()
  return bodies[1], bodies[2]
end

function createAster(world, x, y, vx, vy, r)
  local body = love.physics.newBody(world, x, y, "dynamic")
  local shape = randomPolygonShape(r, r/100)
  local fixture = love.physics.newFixture(body, shape)
  fixture:setFriction(0.9)
  fixture:setRestitution(0.5)
  --body:setLinearVelocity(vx, vy)
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
    local r = love.math.random(ASTER_SIZE)
    x = x + rocket:getX()
    y = y + rocket:getY()
    createAster(world, x, y, vx, vy, r)
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
