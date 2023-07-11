local TextManager = require('textManager')

gold = {}
gold.total = 0
gold.bigSprite = love.graphics.newImage('sprites/coinBig.png')
coins = {}

expTotal = 0

copperSprite = love.graphics.newImage('sprites/coins/coinCopper.png')
copperSheet = love.graphics.newImage('sprites/coins/coinCopper-sheet.png')
silverSprite = love.graphics.newImage('sprites/coins/coinSilver.png')
silverSheet = love.graphics.newImage('sprites/coins/coinSilver-sheet.png')
goldSprite = love.graphics.newImage('sprites/coins/coinGold.png')
goldSheet = love.graphics.newImage('sprites/coins/coinGold-sheet.png')
blackSprite = love.graphics.newImage('sprites/coins/coinBlack.png')
blackSheet = love.graphics.newImage('sprites/coins/coinBlack-sheet.png')
azureSprite = love.graphics.newImage('sprites/coins/coinAzure.png')
azureSheet = love.graphics.newImage('sprites/coins/coinAzure-sheet.png')
rubySprite = love.graphics.newImage('sprites/coins/coinRuby.png')
rubySheet = love.graphics.newImage('sprites/coins/coinRuby-sheet.png')

local values = {
  copper = 1,
  silver = 3,
  gold = 10,
  black = 50,
  azure = 100,
  ruby = 250
}
local collectionDist = 6

function updateGold(dt, magnet)
  for i,c in ipairs(coins) do
    if c.anim then c.anim:update(dt) end
    local coinDistance = distanceBetween(c.x, c.y, player.x, player.y)
    
    if coinDistance > collectionDist and coinDistance < (6 * magnet) then
      c.x = c.x + math.cos(zombie_angle_wrld(c)) * c.speed * dt
      c.y = c.y + math.sin(zombie_angle_wrld(c)) * c.speed * dt
    elseif coinDistance < collectionDist then
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
end

function drawCoins()
  for i,c in ipairs(coins) do
    if c.anim then
      c.anim:draw(c.sheet, c.x, c.y, nil, nil, nil, 2, 2)
    else
      love.graphics.draw(c.sprite, c.x, c.y, nil, nil, nil, 2, 2)
    end
  end
end

function spawnCoin(obj, value, sprite, spriteSheet)
  local coin = {}
  
  coin.x = obj.x + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.y = obj.y + math.random(-obj.goldSpawn, obj.goldSpawn)
  coin.sprite = sprite
  coin.collected = false
  coin.value = value
  coin.speed = math.random(90, 170)
  coin.sheet = spriteSheet
  coin.grid = anim8.newGrid(4,4,16,4)
  coin.anim = anim8.newAnimation(coin.grid('1-4', 1), .06)
  
  table.insert(coins, coin)
end

function spawnGoldReward(zombie)
  while zombie.killReward >= values.ruby do
    spawnCoin(zombie, values.ruby, rubySprite, rubySheet)
    zombie.killReward = zombie.killReward - values.ruby
  end
  
  while zombie.killReward >= values.azure do
    spawnCoin(zombie, values.azure, azureSprite, azureSheet)
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