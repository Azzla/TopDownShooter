local ParticleManager = {}
ParticleManager.tempPsystems = {}
ParticleManager.pTimer = globalTimer.new()

function ParticleManager.new(x, y, p, s) --spawns tracking an in-game object for an abritrary amount of time
  local pFX = {}
  pFX.x = x
  pFX.y = y
  pFX.psys = p
  pFX.s = s
  
  return pFX
end

function ParticleManager.tempNew(x, y, p, s, t) --spawns in a particular location for a specified amount of time
  local pFX = {}
  pFX.x = x
  pFX.y = y
  pFX.psys = p
  pFX.s = math.min(s, 5)
  pFX.dead = false
  ParticleManager.pTimer:after(t, function() pFX.dead = true end)
  
  table.insert(ParticleManager.tempPsystems, pFX)
  return pFX
end

function ParticleManager.spawn(psys, num, angle, inc, mult) --psystem, number of particles, starting angle, angle divided by number of particles, particle multiplier
  local dir = angle
  local increment = inc / num
  
  for i = 1, num do
    psys:setDirection(dir)
    
    psys:emit(mult)
    
    dir = dir + increment
  end
end

function ParticleManager.update(psys, dt) --updates specified particle system
  if psys:isActive() then
    psys:update(dt)
  end
end

function ParticleManager.updateAll(dt) --updates all temporary particle systems
  ParticleManager.pTimer:update(dt)
  
  for i,pt in pairs(ParticleManager.tempPsystems) do
    if pt.psys:isActive() then
      pt.psys:update(dt)
    end
  end
  
  for i=#ParticleManager.tempPsystems,-1 do
    local p = ParticleManager.tempPsystems[i]
    if p.dead then table.remove(ParticleManager.tempPsystems, i) end
  end
end

function ParticleManager.draw(psys, x, y, s) --draws specified particle system at x,y
  love.graphics.draw(psys, x, y, nil, s, s)
end

function ParticleManager.drawAll() --draws all temporary particle systems
  for i,pt in pairs(ParticleManager.tempPsystems) do
    love.graphics.draw(pt.psys, pt.x, pt.y, nil, pt.s, pt.s)
  end
end

function ParticleManager.clearAll() --stop timed functions and immediately delete all psystem instances
  ParticleManager.pTimer:clear()
  ParticleManager.tempPsystems = {}
end

return ParticleManager