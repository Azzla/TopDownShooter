bullets = {}

rocketSprite = love.graphics.newImage('sprites/rocket.png')
reloadTimer = globalTimer.new()
cooldownTimer = globalTimer.new()
explosionTimer = globalTimer.new()
canReload = true
canShoot = true
coolingDown = false

function spawnBullet(damageUp, dir)
  local bullet = {}
  
  bullet.isBullet = true
  bullet.x = player.x
  bullet.y = player.y
  bullet.offsX = guns.equipped.bulletOffsX
  bullet.offsY = guns.equipped.bulletOffsY
  bullet.id = round.bulletCount/1000
  bullet.direction = dir
  bullet.sprite = guns.equipped.bulletSprite
  bullet.frame = bullet.sprite
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
  
  spawnBulletParticles(player.p.pSystem, math.random(6,12))
  world:add(bullet, bullet.x - 1, bullet.y - 1, 2, 2)
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
--      local offsetX, offsetY = bulletAnchorPoints(b.offsX, b.offsY)
      
      local goalX = b.x + math.cos(b.direction - math.pi/2) * b.speed * dt
      local goalY = b.y + math.sin(b.direction - math.pi/2) * b.speed * dt
      local actualX, actualY, cols, length = world:move(b, goalX - 1, goalY - 1, bulletFilter)
      b.x, b.y = actualX + 1, actualY + 1
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
  end
end

function collideWithBullet(b, z)
  if b.id ~= z.id then
    gPopupManager:addPopup(
    {
        text = tostring(b.damage),
        font = pixelFont,
        color = {r = .5, g = .5, b = 1, a = 1},
        x = z.x + math.random(-10,10),
        y = z.y,
        scaleX = .3 + b.damage/75,
        scaleY = .3 + b.damage/75,
        blendMode = 'add',
        fadeOut = {start = .5, finish = .7},
        dX = math.random(-5,5),
        dY = -20,
        duration = .7
    })
    
    spawnBloodParticles(z.p.pSystem, math.random(12,24), b.direction)
    z.zombieDamaged = true
    shaderTimer:after(.15, function() z.zombieDamaged = false end)
    z.health = z.health - b.damage
    z.id = b.id
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

    if b.pierce == 0 then
      b.dead = true
    else
      b.pierce = b.pierce - 1
    end
  end
end

function love.mousereleased(x, y, button)
  if round.gameState == 2 then
    if button == 1 then
      if guns.equipped.currAmmo > 0 and canShoot and not coolingDown then
        if guns.equipped.cooldown > 0 then
          coolingDown = true
          cooldownTimer:after(guns.equipped.cooldown, function() coolingDown = false end)
        end
        
        processGunSounds()
        
        guns.equipped.currAmmo = guns.equipped.currAmmo - 1
        
        if guns.equipped == guns['shotgun'] then
          local bullets = 6
          local direction = player_angle() - math.pi/32
          local increment = math.pi/(math.random(12,18)) / bullets
          
          for i=1,bullets do
            spawnBullet(player.damageUp, direction)
            round.bulletCount = round.bulletCount + 1
            direction = direction + increment
            increment = math.pi/(math.random(12,18)) / bullets
          end
        elseif guns.equipped == guns['pistol'] then
          spawnBullet(player.damageUp, player_angle() - math.pi/14 + math.pi/math.random(11,17))
          round.bulletCount = round.bulletCount + 1
        else
          spawnBullet(player.damageUp, player_angle())
          round.bulletCount = round.bulletCount + 1
        end
        
        spawnBulletParticles(player.p.pSystem, math.random(6,12), player.damageUp)
        if guns.equipped.currAmmo == 0 then reload() end
      elseif guns.equipped.currAmmo == 0 then
        reload()
      end
    elseif button == 2 then
      if shop.skills.grenades >= 1 then
        love.audio.play(soundFX.lazer2)
        spawnGrenade()
        shop.skills.grenades = shop.skills.grenades - 1
      end
    end
  end
end

function bulletAnchorPoints(deltaX,deltaY)
	deltaXrotated = deltaX * cos(player_angle()) - deltaY * sin(player_angle())
  deltaYrotated = deltaX * sin(player_angle()) + deltaY * cos(player_angle())
  
  jointX = playerX + deltaXrotated
  jointY = playerY + deltaYrotated
  return jointX, jointY
end