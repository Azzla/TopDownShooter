grenades = {}

grenadeSprite = love.graphics.newImage('sprites/grenade.png')
grenadeTimer = globalTimer.new()

function spawnGrenade()
  local grenade = {}
  grenade.isGrenade = true
  grenade.x = player.x
  grenade.y = player.y
  grenade.v = 150
  grenade.direction = player_angle()
  grenade.vx = math.cos(grenade.direction - math.pi/2) * grenade.v
  grenade.vy = math.sin(grenade.direction - math.pi/2) * grenade.v
  grenade.rotation = player_angle()
  grenade.rotFactor = 4
  grenade.sprite = grenadeSprite
  grenade.damage = 30
  grenade.dmgRadius = 60
  grenade.dead = false
  grenade.time = .8
  grenade.timer = grenadeTimer:new()
  
  grenade.explode = function()
    grenade.timer:clear()
    grenade.dead = true
    screenShake(.15, 3)
    love.audio.play(soundFX.explosion)
    
    for i,z in ipairs(zombies) do
      if distanceBetween(grenade.x, grenade.y, z.x, z.y) <= grenade.dmgRadius then
        TextManager.grenadeDmgPopup(grenade, z)
        spawnBloodParticles(z.p.pSystem, math.random(12,24), grenade_angle(grenade, z))
        z.zombieDamaged = true
        
        z.health = z.health - grenade.damage
        if soundFX.zombies.hit:isPlaying() == true then
          love.audio.stop(soundFX.zombies.hit)
        end
        love.audio.play(soundFX.zombies.hit)
        
        if z.health <= 0 then
          z.dead = true
          round.totalKilled = round.totalKilled + 1
          round.currentKilled = round.currentKilled + 1
          spawnKillReward(z)
          powerupChance(z)
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
  for i,g in ipairs(grenades) do
    love.graphics.draw(g.sprite, g.x, g.y, g.rotation, 1, 1, grenadeSprite:getWidth()/2, grenadeSprite:getHeight()/2)
  end
end

function grenadeUpdate(dt)
  grenadeTimer:update(dt)
  for i,g in ipairs(grenades) do
    g.timer:update(dt)
    
    local goalX = g.x + g.vx * dt
    local goalY = g.y + g.vy * dt
    local actualX, actualY, cols, length = world:move(g, goalX - grenadeSprite:getWidth()/2, goalY - grenadeSprite:getHeight()/2, grenadeFilter)
    g.x, g.y = actualX + grenadeSprite:getWidth()/2, actualY + grenadeSprite:getHeight()/2
    
    for i=1,length do
      local other = cols[i].other
      if other.isBullet then
        g.explode()
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

  for i=#grenades,1,-1 do
    local g = grenades[i]
    if g.x < 0 or g.y < 0 or g.x > love.graphics.getWidth() or g.y > love.graphics.getHeight() then
      world:remove(g)
      table.remove(grenades, i)
    end
  end

  for i=#grenades,1,-1 do
    local g = grenades[i]
    if g.dead == true then
      world:remove(g)
      table.remove(grenades, i)
    end
  end
end

function spawnExplosion(x,y)
  local explosion = {}
  explosion.x = x
  explosion.y = y
  explosion.sprite = love.graphics.newImage('sprites/explosion.png')
  explosion.grid = anim8.newGrid(16, 16, 128, 16)
  explosion.animation = anim8.newAnimation(explosion.grid("1-8",1), 0.01, explosion.onLoop)
  explosion.dead = false
  explosion.onLoop = function(anim, loops)
    anim:destroy()
    explosion.dead = true
  end

  table.insert(explosions, explosion)
end