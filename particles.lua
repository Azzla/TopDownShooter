particles = {}

bloodSystem = love.graphics.newParticleSystem(zomAssets.bloodParticle, 100)
bloodSystem:setParticleLifetime ( 1,1 )
bloodSystem:setSizeVariation ( .2 )
bloodSystem:setSpeed (5, 5)

function spawnBloodParticleSystem(x, y, pFX)
  pFX.x = x
  pFX.y = y
  pFX.pSystem = bloodSystem
  
  table.insert(particles, pFX)
  
  return pFX
end

function spawnParticles(pSys, numOfParticles)
  local direction = 0
  local increment = (math.pi*2) / numOfParticles
  
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
end