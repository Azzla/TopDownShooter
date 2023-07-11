local TextManager = require('textManager')
local BulletParticleManager = require('particleManager')
local ParticlesDict = require('dicts/particlesDict')

bullets = {}
bloods = {}

reloadTimer = globalTimer.new()
cooldownTimer = globalTimer.new()
warmingTimer = globalTimer.new()
bloodsplat = love.graphics.newImage('sprites/zombies/blood.png')

canReload = true
canShoot = true
coolingDown = false

local bloodSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle1.png'), 100)
bloodSystem:setParticleLifetime ( .05,.4 )
bloodSystem:setSizes(1, .5, .25)
bloodSystem:setSizeVariation ( .5 )
bloodSystem:setSpeed(30, 50)

function drawBullets()
  local fix = 0
  if guns.equipped == guns['railgun'] then fix = 60 end
  local offX,offY = offsetXY(guns.equipped.bulletOffsX, guns.equipped.bulletOffsY + fix, player_angle())
  BulletParticleManager.draw(guns.equipped.pSys, player.x + offX, player.y + offY, 1)
  
  for i,b in ipairs(bullets) do
    if b.anim then
      b.anim:draw(b.sheet, b.x, b.y, b.direction, 1, 1, b.origX, b.origY)
    else
      love.graphics.draw(b.sprite, b.x, b.y, b.direction, 1, 1, b.origX, b.origY)
    end
  end
  for i,bl in ipairs(bloods) do
    love.graphics.setColor(1,1,1,bl.alpha.a)
    love.graphics.draw(bl.sprite, bl.x, bl.y, bl.dir, bl.s, bl.s, 9, 9)
    love.graphics.setColor(1,1,1,1)
  end
end

function fire()
  coolingDown = true
  cooldownTimer:after(guns.equipped.cooldown, function() coolingDown = false end)
  if guns.equipped == guns['railgun'] then
    love.audio.play(guns.equipped.warmSound)
  end
  
  processGunSounds()
  guns.equipped.currAmmo = guns.equipped.currAmmo - 1
--  round.bulletCount = round.bulletCount + 1
  
  --magical magics
  local offX,offY = offsetXY(guns.equipped.bulletOffsX, guns.equipped.bulletOffsY, player_angle())
  
  spawnBullet(player.damageUp, guns.equipped.spread(), offX, offY)
end

function autoShoot(dt)
  if guns.equipped.automatic then
    if guns.equipped.currAmmo > 0 then
      if love.mouse.isDown(1) and canShoot and not coolingDown then
        if guns.equipped.hasWarmup and not guns.equipped.isWarming then
          --warmup stuff
          guns.equipped.isWarming = true
          love.audio.play(guns.equipped.warmSound)
          warmingTimer:after(guns.equipped.warmTime, function()
            guns.equipped.warm = true
            if guns.equipped == guns['chaingun'] then
              love.audio.play(soundFX.firingWarm)
            end
          end)
        end
        
        if guns.equipped.warm or not guns.equipped.hasWarmup and not guns.equipped.bullets then
          fire()
        end
        if guns.equipped.bullets then
          fireBullets()
        end
      end
    else reload() end
  end
end

function spawnBullet(damageUp, direction, offsX, offsY)
  local bullet = {}
  
  bullet.isBullet = true
  bullet.x = player.x + offsX
  bullet.y = player.y + offsY
  bullet.id = true_randomID(math.random(0,99999999))
  bullet.direction = direction
  bullet.sprite = guns.equipped.bulletSprite
  bullet.frame = bullet.sprite
  bullet.origX = bullet.sprite:getWidth()/2
  bullet.origY = bullet.sprite:getHeight()/2
  bullet.damage = guns.equipped.dmg or guns.equipped._dmg()
  bullet.falloff = guns.equipped.falloff
  bullet.pierceFalloff = guns.equipped.pierceFalloff
  if damageUp then bullet.damage = bullet.damage * 2 end
  bullet.critChance = guns.equipped.critChance
  bullet.speed = guns.equipped.v
  bullet.pierce = guns.equipped.pierce
  bullet.knockback = guns.equipped.knockback
  bullet.slowdown = guns.equipped.slowdown
  bullet.dead = false
  
  if guns.equipped.falloff then
    bullet.timer = globalTimer.new()
    bullet.timer:every(bullet.falloff, function()
      if bullet.damage > .5 then
        bullet.damage = bullet.damage - .5
      end
    end)
  end
  BulletParticleManager.spawn(guns.equipped.pSys, unpack(guns.equipped.pSpread(player_angle())))
  
  bullet.coll = HC.rectangle(bullet.x - bullet.origX, bullet.y - bullet.origY, guns.equipped.bulletSprite:getWidth(), guns.equipped.bulletSprite:getHeight())
  bullet.coll.parent = bullet
  bullet.coll:setRotation(bullet.direction)
  
  table.insert(bullets, bullet)
end

function spawnBulletZombie(z)
  local bullet = {}
  
  bullet.isBullet = true
  bullet.isEnemyBullet = true
  bullet.x = z.x
  bullet.y = z.y
  bullet.id = math.random(1, 999999999)/100000
  bullet.direction = z.currentAngle + math.pi/2
  bullet.sprite = z.bulletSprite
  bullet.sheet = z.bulletSheet
  bullet.anim = z.bulletAnimation:clone()
  bullet.origX = bullet.sprite:getWidth()/2
  bullet.origY = bullet.sprite:getHeight()/2
  bullet.damage = z.damage
  --bullet.critChance = z.critChance
  bullet.speed = z.bulletV
  --bullet.pierce = z.pierce
  bullet.dead = false
  
  --BulletParticleManager.spawn(guns.equipped.pSys, unpack(guns.equipped.pSpread(player_angle())))
  
  bullet.coll = HC.circle(z.x, z.y, 2)
  bullet.coll.parent = bullet
  
  table.insert(bullets, bullet)
end

function reload()
  if guns.equipped.hasWarmup then
    guns.equipped.warm = false
    guns.equipped.isWarming = false
    warmingTimer:clear()
    love.audio.stop(guns.equipped.warmSound)
    love.audio.stop(soundFX.firingWarm)
  end
  
  if canReload and guns.equipped.currAmmo < guns.equipped.clipSize then
    canReload = false
    canShoot = false
    
    reloadTween:reset()
    soundFX.reload:play()
    
    reloadTimer:after(guns.equipped.reload, function()
      guns.equipped.currAmmo = guns.equipped.clipSize
      canReload = true
      canShoot = true
    end)
  end
end

local bulletFilter = function(item, other)
  if other.isBullet then return nil end
  if other.isPlayer then return 'cross' end
end

function bulletUpdate(dt)
  BulletParticleManager.update(guns.equipped.pSys, dt)
  
  reloadTimer:update(dt)
  cooldownTimer:update(dt)
  gunTimer:update(dt)
  warmingTimer:update(dt)
  
  for i,b in ipairs(bullets) do
    if b.timer ~= nil then b.timer:update(dt) end
    
    local goalX = b.x + math.cos(b.direction - math.pi/2) * b.speed * dt
    local goalY = b.y + math.sin(b.direction - math.pi/2) * b.speed * dt
    b.coll:moveTo(goalX,goalY)
    
    b.x, b.y = goalX, goalY
    
    if b.isEnemyBullet and not b.dead then
      b.anim:update(dt)
    end
  end
  
  for i=#bullets,1,-1 do
    local b = bullets[i]
    --out of bounds
    if b.x < 0 or b.y < 0 or b.x > SCREEN_W or b.y > SCREEN_H then
      HC.remove(b.coll)
      table.remove(bullets, i)
    end
    
    --dead flag
    if b.dead == true then
      HC.remove(b.coll)
      table.remove(bullets, i)
    end
  end
  
  for i=#bloods,1,-1 do
    local bl = bloods[i]
    bl.tween:update(dt)
    if bl.dead == true then
      table.remove(bloods, i)
    end
  end
end

function criticalHit(chance)
  local random = math.random(1, 100)
  local success = chance * 100
  
  if random <= success then return true end
  return false
end

function spawnBlood(x,y)
  local bl = {}
  bl.sprite = bloodsplat
  bl.alpha = { a = 1 }
  bl.alphaT = { a = 0 }
  bl.tween = tween.new(1.5, bl.alpha, bl.alphaT, "inExpo")
  bl.dir = math.random(0, math.pi*2)
  bl.x = x
  bl.y = y
  bl.s = .8
  bl.dead = false
  
  table.insert(bloods, bl)
  reloadTimer:after(1.5, function() bl.dead = true end)
end

function fireBullets()
  if guns.equipped.hasWarmup then return end
  --check for cooldown
  if guns.equipped.cooldown > 0 then
    coolingDown = true
    cooldownTimer:after(guns.equipped.cooldown, function() coolingDown = false end)
  end
  
  processGunSounds()
  BulletParticleManager.spawn(guns.equipped.pSys, math.random(6,12), player_angle() - math.pi/2 - math.pi/8, math.pi/4, 1)
  guns.equipped.currAmmo = guns.equipped.currAmmo - 1
  
  local handOffsetX,handOffsetY = offsetXY(guns.equipped.bulletOffsX,guns.equipped.bulletOffsY,player_angle())
  
  if guns.equipped.bullets then --its a shotgun lol this is bad code
    local bullets = guns.equipped.bullets
    local direction = player_angle() - guns.equipped.spread()/2 --math.pi/32
    local increment = guns.equipped.spread() / bullets
    
    for i=1,bullets do
      spawnBullet(player.damageUp, direction, handOffsetX, handOffsetY)
--      round.bulletCount = round.bulletCount + 1
      direction = direction + increment
      increment = guns.equipped.spread() / bullets
    end
  else
    spawnBullet(player.damageUp, guns.equipped.spread(), handOffsetX, handOffsetY)
--    round.bulletCount = round.bulletCount + 1
  end
end