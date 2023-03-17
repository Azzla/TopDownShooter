local ZombieParticleManager = require('particleManager')
local TextManager = require('textManager')
local zombieTypes = require('dicts/zombsDict')

zombies = {}

--blood particles
local bloodSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle1.png'), 100)
bloodSystem:setParticleLifetime ( .05,.3 )
bloodSystem:setSizes(1, .5, .25)
bloodSystem:setSizeVariation ( .5 )
bloodSystem:setSpeed(30, 50)

local shootTimer = globalTimer.new()

function drawZombies()
  for i,z in ipairs(zombies) do
    ZombieParticleManager.draw(z.p.psys, z.x, z.y, z.p.s)
    
    if z.zombieDamaged then love.graphics.setShader(damagedShader) end
    z.animation:draw(z.sprite, z.x, z.y, z.currentAngle+math.pi/2, 1, 1, z.oX, z.oY)
    love.graphics.setShader()
    
    if z.healthBar.isHidden == false then
      z.healthBar.animation:draw(z.healthBar.sprite, z.healthBar.x, z.healthBar.y, nil, z.hbScaleX, z.hbScaleY, z.hbOffsX, z.hbOffsY)
    end
  end
end

function spawnZombie(zombieType)
  local side = math.random(1,4)
  local zombie = shallowCopy(zombieTypes[zombieType])
  
  --stats determined at spawn
  zombie.health = zombie._health()
  zombie.killReward = zombie._killReward()
  zombie.speedMax = zombie._speedMax()
  zombie.speedMin = zombie._speedMin()
  if zombie._regen then zombie.regen = zombie._regen(zombie.health) end
  if zombie.fireRate then 
    shootTimer:every(zombie.fireRate, function()
      if not zombie.dead then
        spawnBulletZombie(zombie)
      end
    end)
  end
  
  --defaults
  zombie.isZombie = true
  zombie.x = 0
  zombie.y = 0
  zombie.vx = 0
  zombie.vy = 0
  zombie.id = true_randomID(#zombies+1)
  zombie.currentAngle = 0
  zombie.rotSpeed = 0
  zombie.speed = zombie.speedMin
  zombie.oX = zombie.width/2
  zombie.oY = zombie.height/2
  zombie.healthBar = {}
  zombie.dead = false
  zombie.collideable = true
  zombie.zombieDamaged = false
  
  --animations/particles
  zombie.grid = anim8.newGrid(zombie.frameSize, zombie.frameSize, zombie.sprite:getWidth(), zombie.sprite:getHeight(), nil, nil, zombie.spriteGap)
  zombie.animation = anim8.newAnimation(zombie.grid("1-8", 1), zombie.frameTime)
  zombie.p = ZombieParticleManager.new(zombie.x, zombie.y, bloodSystem:clone(), zombie.pScale)
  
  placeZombie(zombie, side)

  zombie.coll = HC.rectangle(zombie.x,zombie.y,zombie.width*.85,zombie.height*.85)
  zombie.coll.parent = zombie
  
  table.insert(zombie, spawnHealthBar(zombie.health, zombie.x, zombie.y, zombie.healthBar))
  table.insert(zombies, zombie)
end

function zombieUpdate(dt)
  if round.gameState == 2 then
    shootTimer:update(dt)
    for i,z in ipairs(zombies) do
      ZombieParticleManager.update(z.p.psys, dt)
      
      if z.currentAngle ~= zombie_angle_wrld(z) and distanceBetween(player.x, player.y, z.x, z.y) > z.rotActiveDist then
        z.currentAngle = lerp(z.currentAngle, zombie_angle_wrld(z), 1, z.rotSpeed*dt)
      end
      
      zombieMoveHandler(z,dt)
      
      if z.health < z.healthBar.totalHealth then
        
        healthBarUpdate(z.x, z.y, z.healthBar, z.healthBar.animation, z.health, z.healthBar.totalHealth)
        
        if z.regen then
          z.health = z.health + z.regen
          if z.health >= z.healthBar.totalHealth then z.healthBar.isHidden = true end
        end
      end
    end
  end
  
  for i=#zombies,1,-1 do
    local z = zombies[i]
    if z.dead == true then
      HC.remove(z.coll)
      table.remove(zombies, i)
      
      love.audio.stop(soundFX.zombies.death)
      love.audio.play(soundFX.zombies.death)
    end
  end
end

function placeZombie(z, s)
  if s == 1 then
    z.x = player.x - z._spawn()
    z.y = math.random(player.y - z._spawn(), player.y + z._spawn())
  elseif s == 2 then
    z.x = math.random(player.x - z._spawn(), player.x + z._spawn())
    z.y = player.y - z._spawn()
  elseif s == 3 then
    z.x = player.x + z._spawn()
    z.y = math.random(player.y + z._spawn(), player.y - z._spawn())
  elseif s == 4 then
    z.x = math.random(player.x + z._spawn(), player.x - z._spawn())
    z.y = player.y + z._spawn()
  end
end

function collideWithBullet(b, z)
  if b.id ~= z.id then
    ZombieParticleManager.spawn(z.p.psys, math.random(12,24), b.direction - math.pi/2 - math.pi/8, math.pi/4, 3)
    
    z.zombieDamaged = true
    z.healthBar.isHidden = false
    shaderTimer:after(.08, function() z.zombieDamaged = false end)
    
    --Damage
    if criticalHit(b.critChance) then
      local newDmg = b.damage * 3
      z.health = z.health - newDmg
      TextManager.bulletDmgPopup(newDmg, z)
    else
      z.health = z.health - b.damage
      TextManager.bulletDmgPopup(b.damage, z)
    end
    
    z.id = b.id
    z.vx = z.vx * b.knockback
    z.vy = z.vy * b.knockback
    z.speed = z.speed * b.slowdown
    
    love.audio.stop(soundFX.zombies.hit)
    love.audio.play(soundFX.zombies.hit)

    if z.health <= 0 then
      z.collideable = false
      z.dead = true
      
      --death effects
      local deathP = ZombieParticleManager.tempNew(z.x, z.y, bloodSystem:clone(), 2 + ((b.speed - 250) / 100), 3)
      ZombieParticleManager.spawn(deathP.psys, math.random(24,36), b.direction - math.pi/2 - math.pi/8, math.pi/4, 3)
      spawnBlood(z.x,z.y)
      
      round.totalKilled = round.totalKilled + 1
      round.currentKilled = round.currentKilled + 1
      spawnKillReward(z)
      powerupChance(z)
    end

    if b.pierce == 0 then b.dead = true
    else
      b.pierce = b.pierce - 1
      b.damage = b.damage - b.pierceFalloff
      if b.damage <= 1 then b.damage = 1 end
    end
  end
end

function zombie_angle_wrld(enemy)
  local a,b = enemy.x, enemy.y
  local c,d = player.x, player.y
  return math.atan2(d - b, c - a)
end

function lerp(a,b,c,lim)
  return a+math.clamp((short_angle_dist(a, b))*c,-lim,lim)
end

function math.clamp(n, low, high)
  return math.min(math.max(n, low), high)
end

function short_angle_dist(from, to)
  local max_angle = math.pi * 2
  local difference = math.fmod(to - from, max_angle)
  return math.fmod(2 * difference, max_angle) - difference
end

local zombieFilter = function(item, other)
  if other.isZombie then return 'slide'
  elseif other.isBullet then return 'cross'
  elseif other.isGrenade then return 'bounce'
  elseif other.isPlayer then return 'cross' end
end

function zombieMoveHandler(zom,dt)
  zom.animation:update(dt)
  local currentDist = distanceBetween(player.x, player.y, zom.x, zom.y)
  
  if zom.speed < zom.speedMax and currentDist <= zom.activeDist then
    zom.speed = zom.speed * (1 + dt/2)
  elseif zom.speed > zom.speedMin and currentDist > zom.activeDist then
    zom.speed = zom.speed * (1 - dt)
  end
  
  zom.rotSpeed = zom.rotFactor/zom.speed
  zom.vx = zom.vx + math.cos(zom.currentAngle)*zom.speed
  zom.vy = zom.vy + math.sin(zom.currentAngle)*zom.speed
  zom.vx = zom.vx * (1 - math.min(dt*zom.friction, .8))
  zom.vy = zom.vy * (1 - math.min(dt*zom.friction, .8))
  
  local collisions = HC.collisions(zom.coll)
  for other, separating_vector in pairs(collisions) do
    --bullet
    if other.parent and other.parent.isBullet then
      local collides, dx, dy = zom.coll:collidesWith(other)
      if collides and not other.parent.isEnemyBullet and not other.parent.dead then
        collideWithBullet(other.parent, zom)
      end
    end
  end
  
  --collision
  local goalX = zom.x + zom.vx * dt
  local goalY = zom.y + zom.vy * dt
  
  zom.coll:moveTo(goalX,goalY)
  zom.coll:setRotation(zom.currentAngle - math.pi/2)
  
  zom.x = goalX
  zom.y = goalY
  
  --map boundaries
  if zom.x <= 6 then
    zom.vx = zom.vx * -1
    zom.x = zom.x + 2
  end
  if zom.y <= 6 then
    zom.vy = zom.vy * -1
    zom.y = zom.y + 2
  end
  if zom.x >= 1914 then
    zom.vx = zom.vx * -1
    zom.x = zom.x - 2
  end
  if zom.y >= 1074 then
    zom.vy = zom.vy * -1
    zom.y = zom.y - 2
  end
end