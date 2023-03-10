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
  local offX,offY = offsetXY(guns.equipped.bulletOffsX, guns.equipped.bulletOffsY, player_angle())
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
  
  processGunSounds()
  guns.equipped.currAmmo = guns.equipped.currAmmo - 1
  round.bulletCount = round.bulletCount + 1
  
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
          love.audio.play(soundFX.warmup)
          warmingTimer:after(guns.equipped.warmTime, function()
            guns.equipped.warm = true
            if guns.equipped == guns['chaingun'] then
              love.audio.play(soundFX.firingWarm)
            end
          end)
        end
        
        if guns.equipped.warm or not guns.equipped.hasWarmup then
          fire()
        end
      end
    else reload() end
  end
end

function spawnBullet(damageUp, dir, offsX, offsY)
  local bullet = {}
  
  bullet.isBullet = true
  bullet.x = player.x + offsX
  bullet.y = player.y + offsY
  bullet.id = round.bulletCount/1000
  bullet.direction = dir
  bullet.sprite = guns.equipped.bulletSprite
  bullet.frame = bullet.sprite
  bullet.origX = bullet.sprite:getWidth()
  bullet.origY = bullet.sprite:getHeight()/2
  bullet.damage = guns.equipped.dmg
  bullet.falloff = guns.equipped.falloff
  if damageUp then bullet.damage = bullet.damage * 2 end
  if guns.equipped.collision then
    bullet.collW = 4
    bullet.collY = 4
  else
    bullet.collW = 2
    bullet.collY = 2
  end
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
  
  world:add(bullet, bullet.x, bullet.y, bullet.collW, bullet.collY)
  table.insert(bullets, bullet)
end

function spawnBulletZombie(z)
  local bullet = {}
  
  bullet.isBullet = true
  bullet.isEnemyBullet = true
  bullet.x = z.x
  bullet.y = z.y
  bullet.id = round.bulletCount/100000
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
  
  world:add(bullet, bullet.x, bullet.y, 2, 2)
  table.insert(bullets, bullet)
end

function reload()
  if guns.equipped.hasWarmup then
    guns.equipped.warm = false
    guns.equipped.isWarming = false
    warmingTimer:clear()
    love.audio.stop(soundFX.warmup)
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
  
  if round.gameState == 2 then
    for i,b in ipairs(bullets) do
      if b.timer ~= nil then b.timer:update(dt) end
      
      local goalX = b.x + math.cos(b.direction - math.pi/2) * b.speed * dt
      local goalY = b.y + math.sin(b.direction - math.pi/2) * b.speed * dt
      local actualX, actualY, cols, length = world:move(b, goalX, goalY, bulletFilter)
      b.x, b.y = actualX, actualY
      
      if b.isEnemyBullet and not b.dead then
        b.anim:update(dt)
        for i=1,length do
          local other = cols[i].other
          if other.isPlayer then
            collideBulletWithPlayer(b)
          end
        end
      end
    end
    
    for i=#bullets,1,-1 do
      local b = bullets[i]
      if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
        world:remove(b)
        table.remove(bullets, i)
      end
    end

    for i=#bullets,1,-1 do
      local b = bullets[i]
      if b.dead == true then
        world:remove(b)
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
end

function criticalHit(chance)
  local random = math.random(1, 100)
  local success = chance * 100
  
  if random <= success then return true end
  return false
end

function collideBulletWithPlayer(b)
  --Damage
  player.health = player.health - b.damage
  TextManager.playerDmgPopup(player.x, player.y, b)
  shaders.damaged = true
  shaderTimer:after(.1, function() shaders.damaged = false end)
  
  love.audio.stop(soundFX.zombies.hit)
  love.audio.play(soundFX.zombies.hit)

  b.dead = true
end

function collideWithBullet(b, z)
  if b.id ~= z.id then
    BulletParticleManager.spawn(z.p.psys, math.random(12,24), b.direction - math.pi/2 - math.pi/8, math.pi/4, 3)
    
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
      local deathP = BulletParticleManager.tempNew(z.x, z.y, bloodSystem:clone(), 3 + ((b.speed - 250) / 100), 3)
      BulletParticleManager.spawn(deathP.psys, math.random(24,36), b.direction - math.pi/2 - math.pi/8, math.pi/4, 3)
      spawnBlood(z.x,z.y)
      
      round.totalKilled = round.totalKilled + 1
      round.currentKilled = round.currentKilled + 1
      spawnKillReward(z)
      powerupChance(z)
    end

    if b.pierce == 0 then b.dead = true
    else
      b.pierce = b.pierce - 1
      b.damage = b.damage - 7
    end
  end
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
  
  processGunSounds()
  BulletParticleManager.spawn(guns.equipped.pSys, math.random(6,12), player_angle() - math.pi/2 - math.pi/8, math.pi/4, 1)
  guns.equipped.currAmmo = guns.equipped.currAmmo - 1
  
  local handOffsetX,handOffsetY = offsetXY(guns.equipped.bulletOffsX,guns.equipped.bulletOffsY,player_angle())
  
  if guns.equipped.bullets then
    local bullets = guns.equipped.bullets
    local direction = player_angle() - math.pi/32
    local increment = guns.equipped.spread() / bullets
    
    for i=1,bullets do
      spawnBullet(player.damageUp, direction, handOffsetX, handOffsetY)
      round.bulletCount = round.bulletCount + 1
      direction = direction + increment
      increment = guns.equipped.spread() / bullets
    end
  else
    spawnBullet(player.damageUp, guns.equipped.spread(), handOffsetX, handOffsetY)
    round.bulletCount = round.bulletCount + 1
  end
end

function love.mousereleased(x, y, button)
  if round.gameState == 2 and not shopCooldown then
    if button == 1 then
      --stop warming guns with warming time, like chaingun
      if guns.equipped.hasWarmup then
        guns.equipped.warm = false
        guns.equipped.isWarming = false
        warmingTimer:clear()
        love.audio.stop(soundFX.warmup)
        love.audio.stop(soundFX.firingWarm)
      end
      
      if guns.equipped.currAmmo > 0 and canShoot and not coolingDown then
        --check for cooldown
        if guns.equipped.cooldown > 0 then
          coolingDown = true
          cooldownTimer:after(guns.equipped.cooldown, function() coolingDown = false end)
        end
        fireBullets()
        
        if guns.equipped.currAmmo == 0 then reload() end
      elseif guns.equipped.currAmmo == 0 then
        reload()
      end
    elseif button == 2 then
      if shop.skills.grenades >= 1 then
        love.audio.play(soundFX.dash)
        spawnGrenade()
        shop.skills.grenades = shop.skills.grenades - 1
      end
    end
  end
end