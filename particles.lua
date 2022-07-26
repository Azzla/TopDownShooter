particles = {}
deathParticles = {}

bloodSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pFX/particle1.png'), 100)
bloodSystem:setParticleLifetime ( .05,.4 )
bloodSystem:setSizes(1, .5, .25)
bloodSystem:setSizeVariation ( .5 )
bloodSystem:setSpeed(30, 50)

bulletSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pFX/particle2.png'), 100)
bulletSystem:setParticleLifetime (.05, .15)
bulletSystem:setSizes(1)
bulletSystem:setSpeed(120)
bulletSystem:setColors(1, 1, 1, 1, rgb(183), rgb(231), rgb(246), 1)

dashSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pFX/particle2.png'), 100)
dashSystem:setParticleLifetime (.05, .3)
dashSystem:setSizes(1)
dashSystem:setSpeed(60)

function drawPlayerParticles()
  local handDistance = math.sqrt(guns.equipped.bulletOffsX^2 + guns.equipped.bulletOffsY^2)
  local handAngle    = player_angle() + math.atan2(guns.equipped.bulletOffsY, guns.equipped.bulletOffsX)
  local handOffsetX  = handDistance * math.cos(handAngle)
  local handOffsetY  = handDistance * math.sin(handAngle)
  
  love.graphics.draw(player.p.pSystem, player.x + handOffsetX, player.y + handOffsetY, nil, 1, 1)
  love.graphics.draw(player.dashP.pSystem, player.x, player.y, nil, 1, 1)
  for i,d in pairs(deathParticles) do
    love.graphics.draw(d.pSystem, d.x, d.y, nil, 5, 5)
  end
end

function spawnDashParticleSystem(x, y)
  local pFX = {}
  pFX.x = x
  pFX.y = y
  pFX.pSystem = dashSystem:clone()
  
  table.insert(particles, pFX)
  return pFX
end

function spawnDashParticles(pSys, numOfParticles)
  local direction = 0
  local increment = (math.pi * 2) / numOfParticles
  
  for i = 1, numOfParticles do
    pSys:setDirection(direction)
    pSys:emit(3)
    direction = direction + increment
  end
end

function spawnDeathParticleSystem(x, y)
  local pFX = {}
  pFX.x = x
  pFX.y = y
  pFX.pSystem = bloodSystem:clone()
  
  table.insert(deathParticles, pFX)
  return pFX
end

function spawnBloodParticleSystem(x, y)
  local pFX = {}
  pFX.x = x
  pFX.y = y
  pFX.pSystem = bloodSystem:clone()
  
  table.insert(particles, pFX)
  return pFX
end

function spawnBloodParticles(pSys, numOfParticles, angle)
  local direction = angle - math.pi/2 - math.pi/8
  local increment = math.pi/4 / numOfParticles
  
  for i = 1, numOfParticles do
    pSys:setDirection(direction)
    pSys:emit(3)
    direction = direction + increment
  end
end

function spawnBulletParticleSystem(x, y)
  local pFX = {}
  pFX.x = x
  pFX.y = y
  pFX.pSystem = bulletSystem:clone()
  
  table.insert(particles, pFX)
  return pFX
end

function spawnBulletParticles(pSys, numOfParticles, isDamageUp)
  local direction = player_angle() - math.pi/2 - math.pi/8
  local increment = math.pi/4 / numOfParticles
  if isDamageUp then
    pSys:setColors(1, 1, 1, 1, rgb(229), rgb(59), rgb(68), 1)
  else
    pSys:setColors(1, 1, 1, 1, rgb(183), rgb(231), rgb(246), 1)
  end
  
  for i = 1, numOfParticles do
    pSys:setDirection(direction)
    pSys:emit(1)
    direction = direction + increment
  end
end

function particleUpdate(dt)
  for i,p in ipairs(particles) do
    if p.pSystem:isActive() == true then
      p.pSystem:update(dt)
    end
  end
  for i,d in ipairs(deathParticles) do
    if d.pSystem:isActive() == true then
      d.pSystem:update(dt)
    end
  end
end