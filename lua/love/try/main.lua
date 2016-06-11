Entity = {}

function Entity:new()
  e = {}
  setmetatable(e, self)
  e.x = 100
  e.y = 100
  e.components = {}
  return e
end

DrawPlane = {}

function DrawPlane:new(entity)
  d = {}
  setmetatable(d, self)
  d.entity = entity
  return d
end

function DrawPlane:draw()
  love.graphics.draw(planeImg, self.entity.x, self.entity.y)
end

function love.load(arg)
  planeImg = love.graphics.newImage('assets/plane.png')
  plane = Entity:new()
  plane.components:insert(DrawPlane:new(plane))
end

function love.update(dt)
end

function love.draw(dt)
  print("Hello World!")
end
