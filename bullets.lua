bullets = {}
rockets = {}
bulletSprite = love.graphics.newImage('sprites/bullet.png')
bulletSpriteDmg = love.graphics.newImage('sprites/bulletDmg.png')
rocketSprite = love.graphics.newImage('sprites/rocket.png')
currentAmmo = 10
reloadTimer = globalTimer.new()
explosionTimer = globalTimer.new()
canReload = true
canShoot = true

explosions = {}

function spawnBullet(damageUp)
  local bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.id = round.bulletCount/1000
  bullet.direction = player_angle()
  bullet.frame = bullet.sprite
  bullet.speed = 400 + shop.skills.bulletSpeed
  bullet.pierce = 0 + shop.skills.pierce
  bullet.dead = false
  
  if damageUp then
    bullet.damage = shop.skills.damage * damageUpMult
    bullet.sprite = bulletSpriteDmg
    bullet.pierce = 1
  else
    bullet.damage = shop.skills.damage
    bullet.sprite = bulletSprite
  end

  spawnBulletParticles(player.p.pSystem, math.random(6,12))
  table.insert(bullets, bullet)
end

function spawnRocket()
  local rocket = {}
  rocket.x = player.x
  rocket.y = player.y
  rocket.direction = player_angle()
  rocket.sprite = rocketSprite
  rocket.damage = 20 + (shop.skills.damage * 2)
  rocket.speed = 275
  rocket.pierce = 2
  rocket.dead = false
  
  table.insert(rockets, rocket)
end

function reload()
  if canReload and currentAmmo < shop.skills.maxAmmo then
    canReload = false
    canShoot = false
    
    reloadTween:reset()
    soundFX.reload:play()
    reloadTimer:after(shop.skills.reload, function()
      currentAmmo = shop.skills.maxAmmo
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

function explosionUpdate(dt)
  for i,e in ipairs(explosions) do
    e.animation:update(dt)
  end
  for i=#explosions,1,-1 do
      local e = explosions[i]
      if e.dead == true then
        table.remove(explosions, i)
      end
    end
end

function rocketUpdate(dt)
  if round.gameState == 2 then
    for i,r in ipairs(rockets) do
      r.x = r.x + math.cos(r.direction - math.pi/2) * r.speed * dt
      r.y = r.y + math.sin(r.direction - math.pi/2) * r.speed * dt
    end
    
    for i=#rockets,1,-1 do
      local r = rockets[i]
      if r.x < 0 or r.y < 0 or r.x > love.graphics.getWidth() or r.y > love.graphics.getHeight() then
        table.remove(rockets, i)
      end
    end
    
    for i=#rockets,1,-1 do
      local r = rockets[i]
      if r.dead == true then
        table.remove(rockets, i)
      end
    end
    
    for i,z in ipairs(zombies) do
      for j,r in ipairs(rockets) do
        if distanceBetween(z.x, z.y, r.x, r.y) < z.hitRadius then
          if r.id ~= z.id then
            
            spawnBloodParticles(z.p.pSystem, math.random(12,24), r.direction)
            spawnExplosion(r.x, r.y)
            
            z.health = z.health - r.damage
            z.id = r.id
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
            
            r.dead = true
          end
        end
      end
    end
  end
end

function bulletUpdate(dt)
  reloadTimer:update(dt)
  if round.gameState == 2 then
    for i,b in ipairs(bullets) do
      b.x = b.x + math.cos(b.direction - math.pi/2) * b.speed * dt
      b.y = b.y + math.sin(b.direction - math.pi/2) * b.speed * dt
    end
    
    for i=#bullets,1,-1 do
      local b = bullets[i]
      if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
        table.remove(bullets, i)
      end
    end
    
    for i=#bullets,1,-1 do
      local b = bullets[i]
      if b.dead == true then
        table.remove(bullets, i)
      end
    end
    
    for i,z in ipairs(zombies) do
      for j,b in ipairs(bullets) do
        if distanceBetween(z.x, z.y, b.x, b.y) < z.hitRadius then
          if b.id ~= z.id then
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
      end
    end
  end
end

function love.mousereleased(x, y, button)
  if round.gameState == 2 then
    if button == 1 then
      if currentAmmo > 0 and canShoot then
        if soundFX.lazer:isPlaying() == true then
          love.audio.play(soundFX.lazer2)
        else
          love.audio.play(soundFX.lazer)
        end
        round.bulletCount = round.bulletCount + 1
        currentAmmo = currentAmmo - 1
        spawnBullet(player.damageUp)
        spawnBulletParticles(player.p.pSystem, math.random(6,12), player.damageUp)
        
        if currentAmmo == 0 then reload() end
      else
        reload()
      end
    elseif button == 2 then
--      spawnRocket()
--      if soundFX.lazer:isPlaying() == true then
--        love.audio.play(soundFX.lazer2)
--      else
--        love.audio.play(soundFX.lazer)
--      end
    end
  end
end

function autoShoot(dt)
  if round.gameState == 2 then
    if love.mouse.isDown(1) == true then
      if currentAmmo > 0 and canShoot then
        if round.shotTimer <= 0 then
          if soundFX.lazer:isPlaying() == true then
            love.audio.play(soundFX.lazer2)
          else
            love.audio.play(soundFX.lazer)
          end
        round.bulletCount = round.bulletCount + 1
        currentAmmo = currentAmmo - 1
        spawnBullet(player.damageUp)
        spawnBulletParticles(player.p.pSystem, math.random(6,12), player.damageUp)
        round.shotTimer = round.shotMaxTimer * shop.skills.fireRate
        end
        round.shotTimer = round.shotTimer - dt
      else
        reload()
      end
    else
      round.shotTimer = round.shotMaxTimer * shop.skills.fireRate
    end
  else
    for i=#bullets,1,-1 do
      local b = bullets[i]
      table.remove(bullets, i)
    end
  end
end