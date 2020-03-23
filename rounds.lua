round = {}

round.difficulty = 1
round.gameState = 2
round.timer = 2
round.spawnMax = round.timer
round.zombiesSpawned = 0
round.zombiesMaxSpawn = 3
round.totalKilled = 0
round.shotTimer = .1
round.firstShotTaken = false

function updateRounds(dt)
  if round.gameState == 2 then
    round.timer = round.timer - dt
    
    if round.timer <= 0 and #zombies <= 200 then
      spawnZombie()
      round.zombiesSpawned = round.zombiesSpawned + 1
      
      if round.zombiesSpawned == round.zombiesMaxSpawn then
        round.spawnMax = round.spawnMax * .8
        round.zombiesSpawned = 0
        round.difficulty = round.difficulty + 1
      end
      
      if round.difficulty >= 2 then
        round.zombiesMaxSpawn = round.difficulty * 2
      end
      
      round.timer = round.spawnMax
    end
  end
  for i,h in ipairs(healthbars) do
    if h.health <= 0 then
      round.gameState = 2
    end
    if h.health > 100 then
      h.health = 100
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  if round.gameState == 3 and gold.total >= shop.skills.price then
    if key == "z" then
      shop.skills.damage = shop.skills.damage + 10
      gold.total = gold.total - shop.skills.price
      shop.skills.price = shop.skills.price + shop.skills.price*.05
    elseif key == "x" then
      shop.skills.speed = shop.skills.speed + 8
      gold.total = gold.total - shop.skills.price
      shop.skills.price = shop.skills.price + shop.skills.price*.05
    elseif key == "c" then
      shop.skills.fireRate = shop.skills.fireRate * .9
      gold.total = gold.total - shop.skills.price
      shop.skills.price = shop.skills.price + shop.skills.price*.05
    end
  end
  if round.gameState == 3 and gold.total >= shop.skills.healthPrice then
    for i,h in ipairs(healthbars) do
      if key == "b" and h.health < 100 then
        h.health = h.health + 10
        gold.total = gold.total - shop.skills.healthPrice
        shop.skills.healthPrice = 5 + math.ceil(round.difficulty/2)
      end
    end
  end
  if key == "p" then
    if round.gameState == 1 then
      round.gameState = 2
    else
      round.gameState = 1
      round.timer = 1
      round.spawnMax = round.timer
      round.zombiesSpawned = 0
      round.zombiesMaxSpawn = 10
      round.difficulty = 1
    end
  elseif key == "k" then
    if round.gameState == 2 then
      round.gameState = 3
    else
      round.gameState = 2
    end
  end
end