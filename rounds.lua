local TextManager = require('textManager')

round = {}

round.difficulty = 1
round.gameState = 4
round.time = 1
round.next = false
round.zombiesSpawned = 0
round.zombiesMaxSpawn = 10
round.totalKilled = 0
round.currentKilled = 0
round.uiBox = love.graphics.newImage('sprites/ui/UIBox1.png')
round.uiBox2 = love.graphics.newImage('sprites/ui/UIBox2.png')
round.uiBox3 = love.graphics.newImage('sprites/ui/UIBox3.png')
round.bulletCount = 0
round.isDespawning = false
round.despawnText = false
round.despawnTime = 6

roundTimer = globalTimer.new()
dropIndex = 0

roundTimer:every(round.time, function()
  if not round.isDespawning then
    doZombieSpawning()
  end
end)

function updateRounds(dt)
  if round.gameState == 2 then
    if round.zombiesSpawned >= round.zombiesMaxSpawn and #zombies == 0 then
      round.zombiesSpawned = 0
      round.currentKilled = 0
      round.bulletCount = 0
      
      --remove lingering drops
      round.isDespawning = true
      round.despawnText = false
      
      if not round.despawnText then
        round.despawnText = true
        dropIndex = TextManager.dropsDespawning(round.despawnTime)
        player.v = player.v * 1.5
      end
      
      roundTimer:after(round.despawnTime + .1, function()
        round.isDespawning = false
        player.v = player.v / 1.5
        love.audio.play(soundFX.collectCoin)
        
        for i=#coins,1,-1 do
          local c = coins[i]
          c.collected = true
        end
        for i=#powerupsActive,1,-1 do
          local p = powerupsActive[i]
          p.dead = true
        end
        
        shopCooldown = true
        round.gameState = 3
      end)
      
      if round.difficulty >= 10 and round.time ~= 9/round.difficulty then
        round.time = 10/round.difficulty
      end
    end
  end
end

table.insert(KEYPRESSED, function(key, scancode)
  if key == "p" then
    if round.gameState == 1 then
      player.health = 100
      resetRounds()
      resetShop()
      round.gameState = 2
    end
  elseif key == "end" then
    love.event.quit()
  elseif key == "right" then
    if round.gameState == 2 then
      if round.isDespawning then
        TextManager.cancel(dropIndex)
        
        player.v = player.v / 1.5
        round.difficulty = round.difficulty + 1
        love.audio.play(soundFX.roundStart)
        round.zombiesMaxSpawn = math.floor(math.random(5,8)) + round.difficulty
      end
      
      --remove stuff
      for i=#zombies,1,-1 do
        local z = zombies[i]
        world:remove(z)
        table.remove(zombies, i)
      end
      for i=#coins,1,-1 do
        local c = coins[i]
        table.remove(coins, i)
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
  
  if key == '7' then
    spawnZombie(zombieTypes.normal)
  end
  if key == '8' then
    spawnZombie(zombieTypes.big)
  end
  if key == '9' then
    spawnZombie(zombieTypes.small)
  end
end)

function resetRounds()
  if #zombies > 0 then
    for i=#zombies,1,-1 do
      local z = zombies[i]
      world:remove(z)
      table.remove(zombies, i)
    end
  end
  if #bullets > 0 then
    for i=#bullets,1,-1 do
      local b = bullets[i]
      world:remove(b)
      table.remove(bullets, i)
    end
  end
  
  guns.pistol.currAmmo = guns.pistol.clipSize
  guns.sniper.currAmmo = guns.sniper.clipSize
  guns.shotgun.currAmmo = guns.shotgun.clipSize
  guns.equipped = guns.pistol
  
  local items, length = world:getItems()
  for i,item in pairs(items) do
    if item.isZombie or item.isBullet or item.isGrenade then
      world:remove(item)
    end
  end

  gold.total = 0
  round.difficulty = 1
  round.time = 1
  round.zombiesSpawned = 0
  round.zombiesMaxSpawn = 5
  round.totalKilled = 0
  round.currentKilled = 0
  round.isDespawning = false
  round.bulletCount = 0
end
  
function doZombieSpawning()
  if #zombies <= 200 and currentPrompt ~= prompts.wasd and currentPrompt ~= prompts.holdMouse then
    
    if round.zombiesSpawned < round.zombiesMaxSpawn then
      
      spawnZombie(zombieTypes.normal)
      round.zombiesSpawned = round.zombiesSpawned + 1
      
--      if round.difficulty >= 10 and round.zombiesSpawned%6 == 0 then
--        spawnBigZombie()
--        round.zombiesSpawned = round.zombiesSpawned + 1
--      end
--      if round.difficulty >= 20 and round.zombiesSpawned%5 == 0 then
--        spawnSmallZombie()
--        round.zombiesSpawned = round.zombiesSpawned + 1
--      end
    end
    
  end
end