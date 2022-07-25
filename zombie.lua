zombies = {}
zomAssets = {}
zomAssets.zombieFrame = love.graphics.newImage('sprites/zombies/zombie.png')
zomAssets.zombieWidth = zomAssets.zombieFrame:getWidth()
zomAssets.zombieHeight = zomAssets.zombieFrame:getHeight()
zomAssets.zombieSprite = love.graphics.newImage('sprites/zombies/zombieWalk.png')
zomAssets.bigZombieFrame = love.graphics.newImage('sprites/zombies/zombieBig.png')
zomAssets.zombieBigWidth = zomAssets.bigZombieFrame:getWidth()
zomAssets.zombieBigHeight = zomAssets.bigZombieFrame:getHeight()
zomAssets.bigZombieSprite = love.graphics.newImage('sprites/zombies/zombieBigWalk.png')
zomAssets.smallZombieFrame = love.graphics.newImage('sprites/zombies/zombieSmall.png')
zomAssets.smallZombieSprite = love.graphics.newImage('sprites/zombies/zombieSmallWalk.png')

function spawnZombie()
  local side = math.random(1,4)
  local zombie = {}
  zombie.isZombie = true
  zombie.x = 0
  zombie.y = 0
  zombie.vx = 0
  zombie.vy = 0
  zombie.friction = 12
  zombie.id = #zombies + 1
  zombie.currentAngle = 0
  zombie.rotSpeed = 0
  zombie.hitRadius = 9
  zombie.activeDist = 90
  zombie.speedMax = 6 + math.random(0.0,round.difficulty/5)
  zombie.speedMin = 2.5 + math.random(0.0,round.difficulty/5)
  zombie.speed = zombie.speedMin
  zombie.spawn = math.random(280,400)
  zombie.damage = 15
  zombie.sprite = zomAssets.zombieSprite
  zombie.frame = zomAssets.zombieFrame
  zombie.width = zombie.frame:getWidth()
  zombie.height = zombie.frame:getHeight()
  zombie.dead = false
  zombie.collideable = true
  zombie.zombieDamaged = false
  zombie.killReward = 5 + math.random(round.difficulty, math.ceil(round.difficulty*1.7))
  zombie.goldSpawn = 8
  zombie.health = 14 * (1+math.ceil(round.difficulty/3))
  zombie.grid = anim8.newGrid(15, 15, 128, 16, nil, nil, 1)
  zombie.animation = anim8.newAnimation(zombie.grid("1-8",1), 0.12)
  
  zombie.healthBar = {}
  table.insert(zombie, spawnHealthBar(zombie.health, zombie.x, zombie.y, zombie.healthBar))
  
  zombie.p = spawnBloodParticleSystem(zombie.x, zombie.y)
  placeZombie(zombie, side)
  
  world:add(zombie, zombie.x - (zombie.width/2 * .8), zombie.y - (zombie.height/2 * .8), zombie.width * .8, zombie.height * .8)
  table.insert(zombies, zombie)
end

function spawnBigZombie()
  local side = math.random(1,4)
  local zombie = {}
  zombie.isZombie = true
  zombie.x = 0
  zombie.y = 0
  zombie.vx = 0
  zombie.vy = 0
  zombie.friction = 14
  zombie.id = #zombies + 1
  zombie.currentAngle = 0
  zombie.rotSpeed = 0
  zombie.hitRadius = 15
  zombie.activeDist = 120
  zombie.speedMin = 4.5
  zombie.speedMax = 9 + math.random(0,round.difficulty/2)
  zombie.speed = zombie.speedMin
  zombie.spawn = math.random(350,400)
  zombie.damage = 25
  zombie.sprite = zomAssets.bigZombieSprite
  zombie.frame = zomAssets.bigZombieFrame
  zombie.width = zombie.frame:getWidth()
  zombie.height = zombie.frame:getHeight()
  zombie.dead = false
  zombie.zombieDamaged = false
  zombie.killReward = 60 + math.random(round.difficulty*2, round.difficulty*3)
  zombie.goldSpawn = 15
  zombie.health = 55 * (1+math.ceil(round.difficulty/2))
  zombie.grid = anim8.newGrid(30, 30, 256, 32, nil, nil, 2)
  zombie.animation = anim8.newAnimation(zombie.grid("1-8",1), 0.2)
  zombie.healthBar = {}
  table.insert(zombie, spawnHealthBar(zombie.health, zombie.x, zombie.y, zombie.healthBar))
  
  zombie.p = spawnBloodParticleSystem(zombie.x, zombie.y)
  placeZombie(zombie, side)
  
  world:add(zombie, zombie.x - (zombie.width/2 * .8), zombie.y - (zombie.height/2 * .8), zombie.width * .8, zombie.height * .8)
  table.insert(zombies, zombie)
end

function spawnSmallZombie()
  local side = math.random(1,4)
  local zombie = {}
  zombie.isZombie = true
  zombie.x = 0
  zombie.y = 0
  zombie.vx = 0
  zombie.vy = 0
  zombie.friction = 14
  zombie.id = #zombies + 1
  zombie.currentAngle = 0
  zombie.rotSpeed = 0
  zombie.hitRadius = 8
  zombie.activeDist = 100
  zombie.speedMin = 6 + math.random(0,round.difficulty/4)
  zombie.speedMax = 16 + math.random(0,round.difficulty/4)
  zombie.spawn = math.random(270,350)
  zombie.speed = zombie.speedMin
  zombie.damage = 10
  zombie.sprite = zomAssets.smallZombieSprite
  zombie.frame = zomAssets.smallZombieFrame
  zombie.width = zombie.frame:getWidth()
  zombie.height = zombie.frame:getHeight()
  zombie.dead = false
  zombie.zombieDamaged = false
  zombie.killReward = 30 + math.random(round.difficulty*2, round.difficulty*3)
  zombie.health = 14 * (1+math.ceil(round.difficulty/2))
  zombie.goldSpawn = 5
  zombie.grid = anim8.newGrid(13, 13, 128, 16, nil, nil, 3)
  zombie.animation = anim8.newAnimation(zombie.grid("1-8",1), .08)
  zombie.healthBar = {}
  table.insert(zombie, spawnHealthBar(zombie.health, zombie.x, zombie.y, zombie.healthBar))
  
  zombie.p = spawnBloodParticleSystem(zombie.x, zombie.y)
  placeZombie(zombie, side)
  
  world:add(zombie, zombie.x - (zombie.width/2 * .8), zombie.y - (zombie.height/2 * .8), zombie.width * .8, zombie.height * .8)
  table.insert(zombies, zombie)
end

function placeZombie(z, s)
  if s == 1 then
    z.x = player.x - z.spawn
    z.y = math.random(player.y - z.spawn, player.y + z.spawn)
  elseif s == 2 then
    z.x = math.random(player.x - z.spawn, player.x + z.spawn)
    z.y = player.y - z.spawn
  elseif s == 3 then
    z.x = player.x + z.spawn
    z.y = math.random(player.y + z.spawn, player.y - z.spawn)
  elseif s == 4 then
    z.x = math.random(player.x + z.spawn, player.x - z.spawn)
    z.y = player.y + z.spawn
  end
end

function zombieUpdate(dt)
  if round.gameState == 2 then
    for i,z in ipairs(zombies) do
      if z.currentAngle ~= zombie_angle_wrld(z) and distanceBetween(player.x, player.y, z.x, z.y) > 8 then
        z.currentAngle = lerp(z.currentAngle,zombie_angle_wrld(z),1,z.rotSpeed*dt)
      end
      
      zombieMoveHandler(z,dt)
      
      if z.hitRadius ~= 15 and z.health < z.healthBar.totalHealth then
        healthBarUpdate(z.x, z.y, z.healthBar, z.healthBar.animation, z.health, z.healthBar.totalHealth)
      end
      if z.hitRadius == 15 then
        healthBarUpdate(z.x, z.y, z.healthBar, z.healthBar.animation, z.health, z.healthBar.totalHealth)
        if z.health < z.healthBar.totalHealth then
          z.health = z.health + (z.healthBar.totalHealth+round.difficulty*4)/1250
        end
      end
    end
  end
  
  for i=#zombies,1,-1 do
    local z = zombies[i]
    if z.dead == true then
      love.audio.play(soundFX.zombies.death)
      
      world:remove(z)
      table.remove(zombies, i)
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
  if other.isZombie then return nil
  elseif other.isBullet then return 'cross'
  elseif other.isGrenade then return 'bounce'
  elseif other.isPlayer then return 'cross' end
end

function zombieMoveHandler(zom,dt)
  zom.animation:update(dt)
  
  if zom.speed < zom.speedMax and distanceBetween(player.x, player.y, zom.x, zom.y) <= zom.activeDist then
    zom.speed = zom.speed * (1 + dt)
  elseif zom.speed < zom.speedMax and distanceBetween(player.x, player.y, zom.x, zom.y) > zom.activeDist*3 then
    zom.speed = zom.speed * (2 + dt)
  elseif zom.speed > zom.speedMin and distanceBetween(player.x, player.y, zom.x, zom.y) > zom.activeDist then
    zom.speed = zom.speed * (1 - dt)
  end
  
  if zom.damage == 15 then
    zom.rotSpeed = 19/zom.speed
  end
  if zom.damage == 25 then
    zom.rotSpeed = 22/zom.speed
  end
  if zom.damage == 10 then
    zom.rotSpeed = 34/zom.speed
  end
  
  zom.vx = zom.vx + math.cos(zom.currentAngle)*zom.speed
  zom.vy = zom.vy + math.sin(zom.currentAngle)*zom.speed
  zom.vx = zom.vx * (1 - math.min(dt*zom.friction, .8))
  zom.vy = zom.vy * (1 - math.min(dt*zom.friction, .8))
  
  --collision
  local goalX = zom.x + zom.vx * dt
  local goalY = zom.y + zom.vy * dt
  local actualX, actualY, cols, length = world:move(zom, goalX - (zom.width/2 * .8), goalY - (zom.height/2 * .8), zombieFilter)
  zom.x = actualX + (zom.width/2 * .8)
  zom.y = actualY + (zom.height/2 * .8)
  
  for i=1,length do
    local other = cols[i].other
    if other.isBullet then
      collideWithBullet(other, zom)
    elseif other.isPlayer then
      if zom.collideable then
        collideWithZombie(zom)
      end
    end
  end
  
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