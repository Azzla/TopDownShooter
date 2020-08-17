gold = {}
gold.total = 0
gold.bigSprite = love.graphics.newImage('sprites/coinBig.png')
coins = {}
copperSprite = love.graphics.newImage('sprites/coins/coinCopper.png')
silverSprite = love.graphics.newImage('sprites/coins/coinSilver.png')
goldSprite = love.graphics.newImage('sprites/coins/coinGold.png')
blackSprite = love.graphics.newImage('sprites/coins/coinBlack.png')
azureSprite = love.graphics.newImage('sprites/coins/coinAzure.png')
rubySprite = love.graphics.newImage('sprites/coins/coinRuby.png')


function updateGold(dt)
  if round.gameState == 2 then
    for i,c in ipairs(coins) do
      if distanceBetween(c.x, c.y, player.x, player.y) > 6 and distanceBetween(c.x, c.y, player.x, player.y) < (25 * shop.skills.magnet) then
        c.x = c.x + math.cos(zombie_angle_wrld(c)) * c.speed * dt
        c.y = c.y + math.sin(zombie_angle_wrld(c)) * c.speed * dt
      elseif distanceBetween(c.x, c.y, player.x, player.y) < 6 then
        gold.total = gold.total + c.value
        c.collected = true
        calculateCoinAudio()
      end
    end
    
    for i=#coins,1,-1 do
      local c = coins[i]
      if c.collected == true then
        table.remove(coins, i)
      end
    end
  end
end

function spawnRuby(obj)
  local coin = {}
  
  coin.x = obj.x + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.y = obj.y + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.sprite = rubySprite
  coin.collected = false
  coin.value = 250
  coin.speed = math.random(90+math.ceil(shop.skills.magnet*4),170+math.ceil(shop.skills.magnet*4))
  
  table.insert(coins, coin)
end
function spawnAzure(obj)
  local coin = {}
  
  coin.x = obj.x + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.y = obj.y + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.sprite = azureSprite
  coin.collected = false
  coin.value = 100
  coin.speed = math.random(80+math.ceil(shop.skills.magnet*2),140+math.ceil(shop.skills.magnet*2))
  
  table.insert(coins, coin)
end
function spawnBlack(obj)
  local coin = {}
  
  coin.x = obj.x + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.y = obj.y + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.sprite = blackSprite
  coin.collected = false
  coin.value = 50
  coin.speed = math.random(90+math.ceil(shop.skills.magnet*4),170+math.ceil(shop.skills.magnet*4))
  table.insert(coins, coin)
end
function spawnGold(obj)
  local coin = {}
  
  coin.x = obj.x + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.y = obj.y + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.sprite = goldSprite
  coin.collected = false
  coin.value = 10
  coin.speed = math.random(90+math.ceil(shop.skills.magnet*4),170+math.ceil(shop.skills.magnet*4))
  
  table.insert(coins, coin)
end
function spawnSilver(obj)
  local coin = {}
  
  coin.x = obj.x + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.y = obj.y + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.sprite = silverSprite
  coin.collected = false
  coin.value = 3
  coin.speed = math.random(90+math.ceil(shop.skills.magnet*4),170+math.ceil(shop.skills.magnet*4))
  
  table.insert(coins, coin)
end
function spawnCopper(obj)
  local coin = {}
  
  coin.x = obj.x + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.y = obj.y + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.sprite = copperSprite
  coin.collected = false
  coin.value = 1
  coin.speed = math.random(90+math.ceil(shop.skills.magnet*4),170+math.ceil(shop.skills.magnet*4))
  
  table.insert(coins, coin)
end

function spawnKillReward(zombie)
  
  if round.difficulty >= 30 then
    zombie.killReward = zombie.killReward * 1.5
  end
  while zombie.killReward >= 250 do
    spawnRuby(zombie)
    zombie.killReward = zombie.killReward - 250
  end
  while zombie.killReward >= 100 do
    spawnAzure(zombie)
    zombie.killReward = zombie.killReward - 100
  end
  while zombie.killReward >= 50 do
    spawnBlack(zombie)
    zombie.killReward = zombie.killReward - 50
  end
  while zombie.killReward >= 10 do
    spawnGold(zombie)
    zombie.killReward = zombie.killReward - 10
  end
  
  if zombie.killReward > 0 then
    while zombie.killReward >= 3 do
      spawnSilver(zombie)
      zombie.killReward = zombie.killReward - 3
    end
    
    if zombie.killReward > 0 then
      while zombie.killReward >= 1 do
        spawnCopper(zombie)
        zombie.killReward = zombie.killReward - 1
      end
    end
  end
end

function calculateCoinAudio()
  if soundFX.collectCoin.m1:isPlaying() == true then
    if soundFX.collectCoin.m2:isPlaying() == true then
      love.audio.play(soundFX.collectCoin.m5)
      if soundFX.collectCoin.m3:isPlaying() == true then
        love.audio.play(soundFX.collectCoin.m5)
        if soundFX.collectCoin.m4:isPlaying() == true then
          love.audio.play(soundFX.collectCoin.m5)
        else
          love.audio.play(soundFX.collectCoin.m4)
        end
      else
        love.audio.play(soundFX.collectCoin.m3)
      end
    else
      love.audio.play(soundFX.collectCoin.m2)
    end
  else
    love.audio.play(soundFX.collectCoin.m1)
  end
end