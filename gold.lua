local TextManager = require('textManager')

gold = {}
gold.total = 10000
gold.bigSprite = love.graphics.newImage('sprites/coinBig.png')
coins = {}

copperSprite = love.graphics.newImage('sprites/coins/coinCopper.png')
copperSheet = love.graphics.newImage('sprites/coins/coinCopper-sheet.png')
silverSprite = love.graphics.newImage('sprites/coins/coinSilver.png')
silverSheet = love.graphics.newImage('sprites/coins/coinSilver-sheet.png')
goldSprite = love.graphics.newImage('sprites/coins/coinGold.png')
goldSheet = love.graphics.newImage('sprites/coins/coinGold-sheet.png')
blackSprite = love.graphics.newImage('sprites/coins/coinBlack.png')
blackSheet = love.graphics.newImage('sprites/coins/coinBlack-sheet.png')
azureSprite = love.graphics.newImage('sprites/coins/coinAzure.png')
rubySprite = love.graphics.newImage('sprites/coins/coinRuby.png')


local values = {
  copper = 1,
  silver = 3,
  gold = 10,
  black = 50,
  azure = 100,
  ruby = 250
}
local collectionDist = 6

coinAlpha = { alpha = 1 }
targetCoinAlpha = { alpha = 0 }
coinTween = tween.new(.5, coinAlpha, targetCoinAlpha)
local flag = true

function updateGold(dt)
  if round.gameState == 2 then
    for i,c in ipairs(coins) do
      if c.anim then c.anim:update(dt) end
      
      if distanceBetween(c.x, c.y, player.x, player.y) > collectionDist and distanceBetween(c.x, c.y, player.x, player.y) < (25 * shop.skills.magnet) then
        c.x = c.x + math.cos(zombie_angle_wrld(c)) * c.speed * dt
        c.y = c.y + math.sin(zombie_angle_wrld(c)) * c.speed * dt
      elseif distanceBetween(c.x, c.y, player.x, player.y) < collectionDist then
        gold.total = gold.total + c.value
        TextManager.collectCoinPopup(c.x, c.y, tostring(c.value))
        
        c.collected = true
        love.audio.play(soundFX.collectCoin)
      end
    end
    
    for i=#coins,1,-1 do
      local c = coins[i]
      if c.collected == true then
        table.remove(coins, i)
      end
    end
    
    if round.isDespawning then
      if coinAlpha.alpha <= 1 and flag then
        coinTween:update(dt)
        if coinAlpha.alpha == 0 then flag = false end
      end
      if coinAlpha.alpha >= 0 and not flag then
        coinTween:update(-dt)
        if coinAlpha.alpha == 1 then flag = true end
      end
      
    elseif not round.isDespawning and coinAlpha.alpha ~= 1 then coinAlpha.alpha = 1 end
    
  elseif round.gameState == 1 then
    coins = {}
  end
end

function drawCoins()
  love.graphics.setColor(1,1,1,coinAlpha.alpha)
  for i,c in ipairs(coins) do
    if c.anim then
      c.anim:draw(c.sheet, c.x, c.y, nil, nil, nil, 2, 2)
    else
      love.graphics.draw(c.sprite, c.x, c.y, nil, nil, nil, 2, 2)
    end
  end
  love.graphics.setColor(1,1,1,1)
end

function spawnCoin(obj, value, sprite, spriteSheet)
  local coin = {}
  
  coin.x = obj.x + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.y = obj.y + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.sprite = sprite
  coin.collected = false
  coin.value = value
  coin.speed = math.random(90+math.ceil(shop.skills.magnet*4),170+math.ceil(shop.skills.magnet*4))
  
  if spriteSheet then
    coin.sheet = spriteSheet
    coin.grid = anim8.newGrid(4,4,16,4)
    coin.anim = anim8.newAnimation(coin.grid('1-4', 1), .05)
  end
  
  table.insert(coins, coin)
end

function spawnKillReward(zombie)
  while zombie.killReward >= values.ruby do
    spawnCoin(zombie, values.ruby, rubySprite)
    zombie.killReward = zombie.killReward - values.ruby
  end
  
  while zombie.killReward >= values.azure do
    spawnCoin(zombie, values.azure, azureSprite)
    zombie.killReward = zombie.killReward - values.azure
  end
  
  while zombie.killReward >= values.black do
    spawnCoin(zombie, values.black, blackSprite, blackSheet)
    zombie.killReward = zombie.killReward - values.black
  end
  
  while zombie.killReward >= values.gold do
    spawnCoin(zombie, values.gold, goldSprite, goldSheet)
    zombie.killReward = zombie.killReward - values.gold
  end
  
  while zombie.killReward >= values.silver do
    spawnCoin(zombie, values.silver, silverSprite, silverSheet)
    zombie.killReward = zombie.killReward - values.silver
  end
  
  while zombie.killReward >= values.copper do
    spawnCoin(zombie, values.copper, copperSprite, copperSheet)
    zombie.killReward = zombie.killReward - values.copper
  end
end