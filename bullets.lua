bullets = {}
bulletSprite = love.graphics.newImage('sprites/bullet.png')

function spawnBullet()
  local bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.id = round.bulletCount/1000
  bullet.direction = player_angle()
  bullet.sprite = bulletSprite
  bullet.frame = bullet.sprite
  bullet.speed = 400 + shop.skills.bulletSpeed
  bullet.damage = 10 + shop.skills.damage
  bullet.pierce = 0 + shop.skills.pierce
  bullet.dead = false
  
  table.insert(bullets, bullet)
end

function bulletUpdate(dt)
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
            --spawnParticles(z.p.pSystem, math.random(4,8))
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
function autoShoot(dt)
  if round.gameState == 2 then
    if love.mouse.isDown(1) == true then
      if round.firstShotTaken == false then
        if soundFX.lazer:isPlaying() == true then
          love.audio.play(soundFX.lazer2)
        else
          love.audio.play(soundFX.lazer)
        end
        round.bulletCount = round.bulletCount + 1
        spawnBullet()
        round.firstShotTaken = true
      end
      if round.shotTimer <= 0 then
        if soundFX.lazer:isPlaying() == true then
          love.audio.play(soundFX.lazer2)
        else
          love.audio.play(soundFX.lazer)
        end
        round.bulletCount = round.bulletCount + 1
        spawnBullet()
        round.shotTimer = round.shotMaxTimer * shop.skills.fireRate
      end
      round.shotTimer = round.shotTimer - dt
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