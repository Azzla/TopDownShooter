bullets = {}

function spawnBullet()
  local bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.direction = player_angle()
  bullet.sprite = love.graphics.newImage('sprites/bullet.png')
  bullet.frame = bullet.sprite
  bullet.speed = 350 + shop.skills.bulletSpeed
  bullet.damage = 10 + shop.skills.damage
  bullet.pierce = 1 + shop.skills.pierce
  bullet.dead = false
  
  table.insert(bullets, bullet)
end

function bulletUpdate(dt)
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
      if distanceBetween(z.x, z.y, b.x, b.y) < 7 then
        z.health = z.health - b.damage
        if z.health <= 0 then
          z.dead = true
          round.totalKilled = round.totalKilled + 1
          gold.total = gold.total + z.goldReward
        end
        if b.pierce == 1 then
          b.dead = true
        else
          b.pierce = b.pierce - 1
        end
      end
    end
  end
end

function autoShoot(dt)
  if love.mouse.isDown(1) == true then
    if round.firstShotTaken == false then
      spawnBullet()
      round.firstShotTaken = true
    end
    if round.shotTimer <= 0 then
      spawnBullet()
      round.shotTimer = .25 * shop.skills.fireRate
    end
    round.shotTimer = round.shotTimer - dt
  else
    round.shotTimer = .25 * shop.skills.fireRate
    round.firstShotTaken = false
  end
end