zombies = {}

function spawnZombie()
  local side = math.random(1,4)
  local zombie = {}
  zombie.x = 0
  zombie.y = 0
  zombie.speedMin = 35 + (round.difficulty*2)
  zombie.speedMax = 50 + (round.difficulty*2)
  zombie.spawn = 250
  zombie.speed = math.random(zombie.speedMin,zombie.speedMax)
  zombie.damage = 5 + (math.random(0,math.floor(round.difficulty/2)))
  zombie.sprite = love.graphics.newImage('sprites/zombieWalk.png')
  zombie.frame = love.graphics.newImage('sprites/zombie.png')
  zombie.dead = false
  zombie.health = 25 + (round.difficulty*5)
  zombie.grid = anim8.newGrid(15, 15, 128, 16, nil, nil, 1)
  zombie.animation = anim8.newAnimation(zombie.grid("1-8",1), 0.1)
  zombie.goldReward = math.random(1,1+math.floor(round.difficulty/5))
  
  if side == 1 then
    zombie.x = player.x - zombie.spawn
    zombie.y = math.random(player.y - zombie.spawn, player.y + zombie.spawn)
  elseif side == 2 then
    zombie.x = math.random(player.x - zombie.spawn, player.x + zombie.spawn)
    zombie.y = player.y - zombie.spawn
  elseif side == 3 then
    zombie.x = player.x + zombie.spawn
    zombie.y = math.random(player.y + zombie.spawn, player.y - zombie.spawn)
  elseif side == 4 then
    zombie.x = math.random(player.x + zombie.spawn, player.x - zombie.spawn)
    zombie.y = player.y + zombie.spawn
  end
  table.insert(zombies, zombie)
end

function zombieUpdate(dt)
  if round.gameState == 2 then
    for i,z in ipairs(zombies) do
      z.x = z.x + math.cos(zombie_angle_wrld(z)) * z.speed * dt
      z.y = z.y + math.sin(zombie_angle_wrld(z)) * z.speed * dt
    
      z.animation:update(dt)
    end
  end
  
  for i=#zombies,1,-1 do
    local z = zombies[i]
    if z.dead == true then
      table.remove(zombies, i)
    end
  end
end

function zombie_angle_wrld(enemy)
  local a,b = enemy.x, enemy.y
  local c,d = player.x, player.y
  return math.atan2(d - b, c - a)
end