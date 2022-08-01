local TextManager = require('textManager')
local BulletParticleManager = require('particleManager')

bullets = {}
bloods = {}

reloadTimer = globalTimer.new()
cooldownTimer = globalTimer.new()
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
  for i,b in ipairs(bullets) do
    love.graphics.draw(b.sprite, b.x, b.y, b.direction, 1, 1, b.origX, b.origY)
  end
  for i,bl in ipairs(bloods) do
    love.graphics.setColor(1,1,1,bl.alpha.a)
    love.graphics.draw(bl.sprite, bl.x, bl.y, bl.dir, bl.s, bl.s, 9, 9)
    love.graphics.setColor(1,1,1,1)
  end
end

function autoShoot(dt)
  if guns.equipped == guns.uzi then
    if guns.equipped.currAmmo > 0 then
      if love.mouse.isDown(1) and canShoot and not coolingDown then
        coolingDown = true
        cooldownTimer:after(guns.equipped.cooldown, function() coolingDown = false end)
        
        processGunSounds()
        guns.equipped.currAmmo = guns.equipped.currAmmo - 1
        round.bulletCount = round.bulletCount + 1
        --magical magics
        local handDistance = math.sqrt(guns.equipped.bulletOffsX^2 + guns.equipped.bulletOffsY^2)
        local handAngle    = player_angle() + math.atan2(guns.equipped.bulletOffsY, guns.equipped.bulletOffsX)
        local handOffsetX  = handDistance * math.cos(handAngle)
        local handOffsetY  = handDistance * math.sin(handAngle)
        --magical magics
        spawnBullet(player.damageUp, guns.equipped.spread(), handOffsetX, handOffsetY)
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
  bullet.speed = guns.equipped.v
  bullet.pierce = guns.equipped.pierce
  bullet.dead = false
  
  if guns.equipped == guns['shotgun'] then
    bullet.timer = globalTimer.new()
    bullet.timer:every(.02, function()
      if bullet.damage > 1 then
        bullet.damage = bullet.damage - .5
      end
    end)
  end
  
  BulletParticleManager.spawn(player.p.psys, math.random(6,12), player_angle() - math.pi/2 - math.pi/8, math.pi/4, 1)
  world:add(bullet, bullet.x, bullet.y, 2, 2)
  table.insert(bullets, bullet)
end

function reload()
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
end

function bulletUpdate(dt)
  reloadTimer:update(dt)
  cooldownTimer:update(dt)
  gunTimer:update(dt)
  
  if round.gameState == 2 then
    for i,b in ipairs(bullets) do
      if b.timer ~= nil then b.timer:update(dt) end
      
      local goalX = b.x + math.cos(b.direction - math.pi/2) * b.speed * dt
      local goalY = b.y + math.sin(b.direction - math.pi/2) * b.speed * dt
      local actualX, actualY, cols, length = world:move(b, goalX, goalY, bulletFilter)
      b.x, b.y = actualX, actualY
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

function collideWithBullet(b, z)
  if b.id ~= z.id then
    TextManager.bulletDmgPopup(b, z)
    BulletParticleManager.spawn(z.p.psys, math.random(12,24), b.direction - math.pi/2 - math.pi/8, math.pi/4, 3)
    
    z.zombieDamaged = true
    z.healthBar.isHidden = false
    shaderTimer:after(.15, function() z.zombieDamaged = false end)
    
    z.health = z.health - b.damage
    z.id = b.id
    
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
  --magical magics
  local handDistance = math.sqrt(guns.equipped.bulletOffsX^2 + guns.equipped.bulletOffsY^2)
  local handAngle    = player_angle() + math.atan2(guns.equipped.bulletOffsY, guns.equipped.bulletOffsX)
  local handOffsetX  = handDistance * math.cos(handAngle)
  local handOffsetY  = handDistance * math.sin(handAngle)
  --magical magics
  
  if guns.equipped == guns['shotgun'] then
    local bullets = guns.equipped.bullets
    local direction = player_angle() - math.pi/32
    local increment = guns.equipped.spread() / bullets
    
    for i=1,bullets do
      spawnBullet(player.damageUp, direction, handOffsetX, handOffsetY)
      round.bulletCount = round.bulletCount + 1
      direction = direction + increment
      increment = guns.equipped.spread() / bullets
    end
    
  elseif guns.equipped == guns['pistol'] then
    spawnBullet(player.damageUp, guns.equipped.spread(), handOffsetX, handOffsetY)
    round.bulletCount = round.bulletCount + 1
    
  elseif guns.equipped == guns['sniper'] then
    spawnBullet(player.damageUp, player_angle(), handOffsetX, handOffsetY)
    round.bulletCount = round.bulletCount + 1
  end
end

function love.mousereleased(x, y, button)
  if round.gameState == 2 and not shopCooldown then
    if button == 1 then
      if guns.equipped.currAmmo > 0 and canShoot and not coolingDown then
        --check for cooldown
        if guns.equipped.cooldown > 0 then
          coolingDown = true
          cooldownTimer:after(guns.equipped.cooldown, function() coolingDown = false end)
        end
        
        processGunSounds()
        BulletParticleManager.spawn(player.p.psys, math.random(6,12), player_angle() - math.pi/2 - math.pi/8, math.pi/4, 1)
        guns.equipped.currAmmo = guns.equipped.currAmmo - 1
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