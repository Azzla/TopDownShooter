local DecisionTree = {}
local decision_timer = globalTimer.new()

--Movement Functions--
local function start(z)
  z.speed = z.speedMin
  z.animation:gotoFrame(1)
  z.animation:resume()
end

local function stop(z)
  z.speed = 0
  z.animation:gotoFrame(1)
  z.animation:pause()
end

local function accelerate(p_dist, z, dt)
  if p_dist > z.activeDist and z.speed > 0 and z.speed < z.speedMax then
    z.speed = z.speed * (1+z.acceleration*dt)
  end
end

local function decelerate(p_dist, z, dt)
  if p_dist < z.activeDist and z.speed > z.speedMax then
    z.speed = z.speed * (1-z.acceleration*dt)
  end
end

local function lunge(p_dist, z, dt)
  if z.canLunge then
    if p_dist < z.lungeDist then
      decision_timer:after(z.lungeTime, function() z.speed = z.speedMax end)
      decision_timer:after(z.lungeTime * 3, function() z.canLunge = true end)
      
      z.canLunge = false
      z.speed = z.speedMax * 2.5
      z.animation:gotoFrame(1)
      z.animation:resume()
    end
  end
end

local function every_lunge(p_dist, z, dt)
  if z.everyLunge then
    z.everyLunge = false
    decision_timer:every(math.random(4,10), function()
      decision_timer:after(z.lungeTime, function() z.speed = z.speedMax end)
      
      z.speed = z.speedMax * 1.5
      z.animation:gotoFrame(1)
      z.animation:resume()
    end)
  end
end

------

function DecisionTree.update(dt)
  decision_timer:update(dt)
end

function DecisionTree.normal(p_dist, z, dt)
  --start
  if z.speed == 0 then start(z) end
  
  accelerate(p_dist, z, dt)
  decelerate(p_dist, z, dt)
  every_lunge(p_dist, z, dt)
  lunge(p_dist, z, dt)
end

function DecisionTree.big(p_dist, z, dt)
  --start
  if z.speed == 0 then start(z) end
  
  accelerate(p_dist, z, dt)
  lunge(p_dist, z, dt)
end

function DecisionTree.small(p_dist, z, dt)
  --start
  if z.speed == 0 then start(z) end
  
  lunge(p_dist, z, dt)
end

function DecisionTree.shooter(p_dist, z, dt)
  --start
  if p_dist > z.activeDist and z.speed == 0 then start(z) end
  --stop
  if p_dist < z.activeDist and p_dist > 30 then stop(z) end
end

return DecisionTree