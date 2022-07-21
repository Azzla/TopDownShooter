round = {}

round.difficulty = 1
round.gameState = 4
round.time = 1
round.next = false
round.zombiesSpawned = 0
round.zombiesMaxSpawn = 5
round.totalKilled = 0
round.currentKilled = 0
round.shotTimer = round.shotMaxTimer or .4
round.shotMaxTimer = .4
round.uiBox = love.graphics.newImage('sprites/UIBox1.png')
round.uiBox2 = love.graphics.newImage('sprites/UIBox2.png')
round.uiBox3 = love.graphics.newImage('sprites/UIBox3.png')
round.bulletCount = 0

roundTimer = globalTimer.new()

roundTimer:every(round.time, function() zombieSpawning() end)

function updateRounds(dt)
  if round.gameState == 2 then
    if round.zombiesSpawned >= round.zombiesMaxSpawn and #zombies == 0 then
      round.zombiesSpawned = 0
      round.currentKilled = 0
      round.bulletCount = 0
      round.difficulty = round.difficulty + 1
      
      if round.difficulty >= 10 and round.time ~= 9/round.difficulty then
        round.time = 10/round.difficulty
      end
      
      love.audio.play(soundFX.roundStart)
      round.zombiesMaxSpawn = math.floor(math.random(5,8)) + round.difficulty
    end
  end
  
  for i,h in ipairs(healthbars) do
    if h.isPlayer == true and h.health <= 0 then
      round.gameState = 1
      h.health = player.health
      resetRounds()
      resetShop()
      round.gameState = 2
    end
    if h.health > player.health then
      h.health = player.health
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "p" then
    if round.gameState == 1 then
      player.health = 100
      resetRounds()
      resetShop()
      round.gameState = 2
    end
  elseif key == "end" then
    love.event.quit()
  elseif key == "lshift" then
    if round.gameState == 2 then
      round.gameState = 3
      love.audio.play(soundFX.collectCoin)
    elseif round.gameState == 3 then
      round.gameState = 2
      soundFX.music:setVolume(.3)
    end
  elseif key == 'space' then
    if round.gameState == 2 then
      if player.canDash == true then
        
        love.audio.play(soundFX.dash)
        spawnDashParticles(player.dashP.pSystem, math.random(12,24))
        player.canDash = false
        player.isRecharge = false
        
        if love.keyboard.isDown("a") then
          player.vx = player.vx - (player.v+shop.skills.speed)/2
        end
        if love.keyboard.isDown("d") then
          player.vx = player.vx + (player.v+shop.skills.speed)/2
        end
        if love.keyboard.isDown("w") then
          player.vy = player.vy - (player.v+shop.skills.speed)/2
        end
        if love.keyboard.isDown("s") then
          player.vy = player.vy + (player.v+shop.skills.speed)/2
        end
        dashTween:reset()
      end
    end
  elseif key == "right" then
    if round.gameState == 2 then
      for i=#zombies,1,-1 do
        local z = zombies[i]
        table.remove(zombies, i)
      end
      round.zombiesSpawned = 0
      round.currentKilled = 0
      round.difficulty = round.difficulty + 1
      if round.difficulty >= 10 and round.time ~= 9/round.difficulty then
        round.time = 10/round.difficulty
      end
      love.audio.play(soundFX.roundStart)
      round.zombiesMaxSpawn = math.floor(math.random(3,5)) + round.difficulty
    elseif round.gameState == 3 then
      gold.total = gold.total + 1000
      love.audio.play(soundFX.makePurchase)
    end
  elseif key == "escape" then
    if round.gameState == 4 or round.gameState == 6 or round.gameState == 3 then return end
    if round.gameState == 5 then
      round.gameState = 2
    else
      round.gameState = 5
    end
  end
  
--  if key == '1' then
--    spawnZombie()
--  end
--  if key == '2' then
--    spawnBigZombie()
--  end
--  if key == '3' then
--    spawnSmallZombie()
--  end
  
  if round.gameState == 2 and canReload and key == 'r' then
    reload()
  end
end

function resetRounds()
  if #zombies > 0 then
    for i=#zombies,1,-1 do
      local z = zombies[i]
      table.remove(zombies, i)
    end
  end

  gold.total = 0
  round.difficulty = 1
  round.time = 3
  round.zombiesSpawned = 0
  round.zombiesMaxSpawn = 5
  round.totalKilled = 0
  round.currentKilled = 0
  round.shotTimer = .1
  round.firstShotTaken = false
end
  
function zombieSpawning()
  if #zombies <= 200 and currentPrompt ~= prompts.wasd and currentPrompt ~= prompts.holdMouse then
    if round.zombiesSpawned < round.zombiesMaxSpawn then
      spawnZombie()
      round.zombiesSpawned = round.zombiesSpawned + 1
      if round.difficulty >= 10 and round.zombiesSpawned%6 == 0 then
        spawnBigZombie()
      end
      if round.difficulty >= 20 and round.zombiesSpawned%5 == 0 then
        spawnSmallZombie()
      end
    end
  end
end