local GrenadeParticleManager = require('particleManager')

grenades = {}
explosions = {}

grenadeSprite = love.graphics.newImage('sprites/grenade.png')
grenadeTimer = globalTimer.new()

local bloodSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle1.png'), 100)
bloodSystem:setParticleLifetime ( .05,.4 )
bloodSystem:setSizes(1, .5, .25)
bloodSystem:setSizeVariation ( .5 )
bloodSystem:setSpeed(30, 50)

local explosionSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle3.png'), 1000)
explosionSystem:setParticleLifetime (.05, .4)
explosionSystem:setSizes(2, 1, 1.5, .5)
explosionSystem:setSpeed(60,80)

function spawnGrenade()
  local grenade = {}
  grenade.isGrenade = true
  grenade.x = player.x
  grenade.y = player.y
  grenade.v = 100
  grenade.direction = player_angle()
  grenade.vx = math.cos(grenade.direction - math.pi/2) * grenade.v
  grenade.vy = math.sin(grenade.direction - math.pi/2) * grenade.v
  grenade.rotation = player_angle()
  grenade.rotFactor = 4
  grenade.sprite = grenadeSprite
  grenade.damage = 25
  grenade.dmgRadius = 60
  grenade.dead = false
  grenade.bulletCollisions = true
  grenade.time = .8
  grenade.timer = grenadeTimer:new()
  
  grenade.explode = function()
    grenade.timer:clear()
    grenade.dead = true
    screenShake(.15, 3)
    love.audio.play(soundFX.explosion)
    spawnExplosion(grenade.x, grenade.y)
    local p = GrenadeParticleManager.tempNew(grenade.x, grenade.y, explosionSystem:clone(), 2, 2)
    GrenadeParticleManager.spawn(p.psys, 100, 0, math.pi * 2, 3)
    
    for i,z in ipairs(zombies) do
      if distanceBetween(grenade.x, grenade.y, z.x, z.y) <= grenade.dmgRadius then
        TextManager.grenadeDmgPopup(grenade, z)
        GrenadeParticleManager.spawn(z.p.psys, math.random(12,24), grenade_angle(grenade, z) - math.pi/2 - math.pi/8, math.pi/4, 3)
        
        z.zombieDamaged = true
        shaderTimer:after(.08, function() z.zombieDamaged = false end)
        
        z.healthBar.isHidden = false
        z.health = z.health - grenade.damage
        love.audio.stop(soundFX.zombies.hit)
        love.audio.play(soundFX.zombies.hit)
        
        if z.health <= 0 then
          z.dead = true
          round.totalKilled = round.totalKilled + 1
          round.currentKilled = round.currentKilled + 1
          spawnKillReward(z)
          powerupChance(z)
          
          local deathP = GrenadeParticleManager.tempNew(z.x, z.y, bloodSystem:clone(), 3 + ((grenade.v * 5 - 250) / 100), 3)
          GrenadeParticleManager.spawn(deathP.psys, math.random(24,36), grenade_angle(grenade, z) - math.pi/2 - math.pi/8, math.pi/4, 3)
          
          spawnBlood(z.x,z.y)
        end
      end
    end
  end
  
  grenade.timer:after(grenade.time, grenade.explode)
  
  world:add(grenade, grenade.x - grenadeSprite:getWidth()/2, grenade.y - grenadeSprite:getHeight()/2, grenadeSprite:getWidth(), grenadeSprite:getHeight())
  table.insert(grenades, grenade)
end

local grenadeFilter = function(item, other)
  if other.isBullet then return 'cross'
  elseif other.isGrenade then return nil
  elseif other.isPlayer then return nil
  elseif other.isZombie then return 'bounce' end
end

function drawGrenades()
  GrenadeParticleManager.drawAll()
  for i,g in ipairs(grenades) do
    love.graphics.draw(g.sprite, g.x, g.y, g.rotation, 1, 1, grenadeSprite:getWidth()/2, grenadeSprite:getHeight()/2)
  end
  for i,e in ipairs(explosions) do
    e.animation:draw(e.sprite, e.x, e.y, nil, 2, 2, 15.5, 15.5)
  end
end

function grenadeUpdate(dt)
  grenadeTimer:update(dt)
  GrenadeParticleManager.updateAll(dt)
  
  for i,g in ipairs(grenades) do
    g.timer:update(dt)
    
    local goalX = g.x + g.vx * dt
    local goalY = g.y + g.vy * dt
    local actualX, actualY, cols, length = world:move(g, goalX - grenadeSprite:getWidth()/2, goalY - grenadeSprite:getHeight()/2, grenadeFilter)
    g.x, g.y = actualX + grenadeSprite:getWidth()/2, actualY + grenadeSprite:getHeight()/2
    
    for i=1,length do
      local other = cols[i].other
      if other.isBullet then
        if g.bulletCollisions then
          g.explode()
          g.bulletCollisions = false
        end
        other.dead = true
      elseif other.isZombie then
        g.rotFactor = g.rotFactor / 2
        
        local nx, ny = cols[i].normal.x, cols[i].normal.y
        if (nx < 0 and g.vx > 0) or (nx > 0 and g.vx < 0) then
          g.vx = -g.vx * .01
        end

        if (ny < 0 and g.vy > 0) or (ny > 0 and g.vy < 0) then
          g.vy = -g.vy * .01
        end
      end
    end
    
    g.rotation = g.rotation + math.pi * g.rotFactor * dt
  end
  for i,e in ipairs(explosions) do
    e.animation:update(dt)
  end

  for i=#grenades,1,-1 do
    local g = grenades[i]
    if g.x < 0 or g.y < 0 or g.x > love.graphics.getWidth() or g.y > love.graphics.getHeight() then
      world:remove(g)
      table.remove(grenades, i)
    end
  end

  for i=#grenades,1,-1 do
    local g = grenades[i]
    if g.dead then
      world:remove(g)
      table.remove(grenades, i)
    end
  end
  
  for i=#explosions,1,-1 do
    local e = explosions[i]
    if e.dead then
      table.remove(explosions, i)
    end
  end
end

function spawnExplosion(x,y)
  local explosion = {}
  explosion.x = x
  explosion.y = y
  explosion.sprite = love.graphics.newImage('sprites/explosion.png')
  explosion.grid = anim8.newGrid(31, 31, 236, 31, -3, -3, 3)
  explosion.animation = anim8.newAnimation(explosion.grid("1-7",1), 0.05, 'pauseAtEnd')
  explosion.dead = false
  
  grenadeTimer:after(.35, function() explosion.dead = true end)
  
  table.insert(explosions, explosion)
end