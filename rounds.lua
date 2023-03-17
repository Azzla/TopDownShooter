local TextManager = require('textManager')

round = {}

round.difficulty = 1
round.gameState = 4
round.time = .6
round.next = false
round.zombiesSpawned = 0
round.zombiesMaxSpawn = 5
round.totalKilled = 0
round.currentKilled = 0
round.uiBox = love.graphics.newImage('sprites/ui/UIBox1.png')
round.uiBox2 = love.graphics.newImage('sprites/ui/UIBox2.png')
round.uiBox3 = love.graphics.newImage('sprites/ui/UIBox3.png')
round.bulletCount = 0
round.isDespawning = false
round.despawnText = false
round.despawnTime = 5

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
      end
      
      roundTimer:after(round.despawnTime + .1, function()
        round.isDespawning = false
--        love.audio.play(soundFX.collectCoin)
        
        for i=#coins,1,-1 do
          local c = coins[i]
          c.collected = true
        end
        for i=#powerupsActive,1,-1 do
          local p = powerupsActive[i]
          p.dead = true
        end
        
        round.zombiesMaxSpawn = round.zombiesMaxSpawn + math.max(3, round.difficulty)
        round.difficulty = round.difficulty + 1
        love.audio.play(soundFX.roundStart)
        
        if round.difficulty % 5 == 0 then
          shopCooldown = true
          round.gameState = 3
        else
          
        end
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
    -- TODO:  this is some serious bullshit
    if round.gameState == 2 then
      if round.isDespawning then
        TextManager.cancel(dropIndex)
        
        round.difficulty = round.difficulty + 1
        love.audio.play(soundFX.roundStart)
        round.zombiesMaxSpawn = round.zombiesMaxSpawn + math.max(3, round.difficulty)
      else
        --remove stuff
        if #zombies > 0 then
          for i=#zombies,1,-1 do
            local z = zombies[i]
            z.dead = true
          end
        end
        for i=#coins,1,-1 do
          local c = coins[i]
          c.dead = true
        end
        for i=#bullets,1,-1 do
          local b = bullets[i]
          b.dead = true
        end
        
        round.zombiesSpawned = 0
        round.currentKilled = 0
        round.difficulty = round.difficulty + 1
        if round.difficulty >= 10 and round.time ~= 9/round.difficulty then
          round.time = 10/round.difficulty
        end
        love.audio.play(soundFX.roundStart)
        round.zombiesMaxSpawn = round.zombiesMaxSpawn + math.max(3, round.difficulty)
      end

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
  elseif key == "h" then
    if round.gameState == 2 then
      if love.keyboard.isDown('j','k') then
        guns.equipped.currAmmo = 999999
        player.v = 1500
        player.health = 999999
      end
    end
  end
end)

function resetRounds()
  if #zombies > 0 then
    for i=#zombies,1,-1 do
      local z = zombies[i]
      HC.remove(z.coll)
      table.remove(zombies, i)
    end
  end
  if #bullets > 0 then
    for i=#bullets,1,-1 do
      local b = bullets[i]
      HC.remove(b.coll)
      table.remove(bullets, i)
    end
  end
  
  guns.pistol.currAmmo = guns.pistol.clipSize
  guns.sniper.currAmmo = guns.sniper.clipSize
  guns.shotgun.currAmmo = guns.shotgun.clipSize
  guns.equipped = guns.pistol

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
  if #zombies <= 200 then
    if round.zombiesSpawned < round.zombiesMaxSpawn then
      spawnZombie('shooter')
      round.zombiesSpawned = round.zombiesSpawned + 1
      
      if round.difficulty >= 5 and round.zombiesSpawned%10 == 0 then
        spawnZombie('big')
        for i=1,2 do spawnZombie('small') end
        round.zombiesSpawned = round.zombiesSpawned + 1
      end
      if round.difficulty >= 10 and round.zombiesSpawned%5 == 0 then
        spawnZombie('small')
        round.zombiesSpawned = round.zombiesSpawned + 1
      end
    end
    
  end
end