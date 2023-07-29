local Gold = {}

function Gold:init()
  self.textManager = require('textManager')
  self.total = 0
  self.bigSprite = love.graphics.newImage('sprites/coinBig.png')
  self.activeCoins = {}
  self.collectionDist = 6
  self.dict = require("dicts/coinDict")
end

function Gold:update(dt, magnet, despawning)
  for i,c in ipairs(self.activeCoins) do
    if c.anim then c.anim:update(dt) end
    local coinDistance = distanceBetween(c.x, c.y, player.x, player.y)
    
    if coinDistance > self.collectionDist and coinDistance < (9 * magnet) then
      c.x = c.x + math.cos(zombie_angle_wrld(c)) * c.speed * dt
      c.y = c.y + math.sin(zombie_angle_wrld(c)) * c.speed * dt
    elseif coinDistance < self.collectionDist then
      local factor = 1
      if despawning then factor = 2 end
      self.total = self.total + (c.value/factor)
      --self.textManager.collectCoinPopup(c.x, c.y, tostring(c.value))
      
      c.collected = true
      love.audio.play(soundFX.collectCoin)
    end
  end
  
  for i=#self.activeCoins,1,-1 do
    local c = self.activeCoins[i]
    if c.collected == true then
      table.remove(self.activeCoins, i)
    end
  end
end

function Gold:draw()
  for i,c in ipairs(self.activeCoins) do
    if c.anim then
      c.anim:draw(c.sheet, c.x, c.y, nil, nil, nil, 2, 2)
    else
      love.graphics.draw(c.sprite, c.x, c.y, nil, nil, nil, 2, 2)
    end
  end
end

function Gold:spawnCoin(obj, value, sprite, spriteSheet)
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
  
  table.insert(self.activeCoins, coin)
end

function Gold:reward(zombie)
  local values = self.dict.values
  local sprites = self.dict.sprites
  
  while zombie.killReward >= values.ruby do
    self:spawnCoin(zombie, values.ruby, sprites.rubySprite, sprites.rubySheet)
    zombie.killReward = zombie.killReward - values.ruby
  end
  
  while zombie.killReward >= values.azure do
    self:spawnCoin(zombie, values.azure, sprites.azureSprite, sprites.azureSheet)
    zombie.killReward = zombie.killReward - values.azure
  end
  
  while zombie.killReward >= values.black do
    self:spawnCoin(zombie, values.black, sprites.blackSprite, sprites.blackSheet)
    zombie.killReward = zombie.killReward - values.black
  end
  
  while zombie.killReward >= values.gold do
    self:spawnCoin(zombie, values.gold, sprites.goldSprite, sprites.goldSheet)
    zombie.killReward = zombie.killReward - values.gold
  end
  
  while zombie.killReward >= values.silver do
    self:spawnCoin(zombie, values.silver, sprites.silverSprite, sprites.silverSheet)
    zombie.killReward = zombie.killReward - values.silver
  end
  
  while zombie.killReward >= values.copper do
    self:spawnCoin(zombie, values.copper, sprites.copperSprite, sprites.copperSheet)
    zombie.killReward = zombie.killReward - values.copper
  end
end

return Gold