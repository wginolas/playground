local function dist(x1, y1, x2, y2)
  local dx, dy = x2 - x1, y2 - y1
  return math.sqrt(dx*dx + dy*dy)
end

local function rnd(min, max)
  return love.math.random() * (max - min) + min
end

local function randomPointInCircle(rOuter, rInner)
  local x, y, d
  repeat
    x, y = rnd(-rOuter, rOuter), rnd(-rOuter, rOuter)
    d = dist(0, 0, x, y)
  until d<=rOuter and d>=rInner
  return x, y
end

return {
  dist = dist,
  rnd = rnd,
  randomPointInCircle = randomPointInCircle
}
