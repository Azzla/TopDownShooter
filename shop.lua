local shopButtonManager = require('buttonManager')

local shop = {}
shop.skills = {}
shop.skills.price = 100
shop.skills.grenades = 100
shop.skills.damage = 0
shop.skills.damPurch = 0
shop.skills.speedPurch = 0
shop.skills.reloadPurch = 0
shop.skills.magPurch = 0
shop.skills.ammoPurch = 0
shop.skills.maxAmmo = 0
shop.skills.reload = 0
shop.skills.speed = 0
shop.skills.magnet = 1
shop.rate = 1

function shop:init()
  self.btnsCreated = false
  self.buttons = nil
  self.timer = globalTimer.new()
  self.nextClicked = false
  self.cooldown = false
  self.currentScreen = 1

  self.buttonSprite = love.graphics.newImage('sprites/ui/shopButton.png')
  self.buttonSpriteHot = love.graphics.newImage('sprites/ui/shopButtonHot.png')
  self.uiBox3 = love.graphics.newImage('sprites/ui/UIBox3.png')
  self.continue = love.graphics.newImage('sprites/ui/UIBox1.png')
  self.continueHover = love.graphics.newImage('sprites/ui/UIBox1Hover.png')
  self.display = love.graphics.newImage('sprites/ui/UIShop.png')
  self.displayHot = love.graphics.newImage('sprites/ui/UIShopHot.png')
  self.offsetX = self.display:getWidth() / 8
  self.offsetY = self.display:getHeight() / 8
  
  self.icons = {
    ammo = love.graphics.newImage('sprites/ui/ammo.png'),
    reload = love.graphics.newImage('sprites/ui/reload.png'),
    speed = love.graphics.newImage('sprites/ui/speed.png'),
    damage = love.graphics.newImage('sprites/ui/damage.png'),
    accuracy = love.graphics.newImage('sprites/ui/accuracy.png'),
    magnet = love.graphics.newImage('sprites/ui/magnet.png'),
    unpurchased = love.graphics.newImage('sprites/ui/unpurchased.png'),
    purchased = love.graphics.newImage('sprites/ui/purchased.png')
  }
  
  self.textScale = 1/2
  self.x = 0
  self.y = 0

  --define functions for purchasing skills
  self.skillList = { "damPurch", "reloadPurch", "ammoPurch", "speedPurch", "magPurch" }
  self.purchases = {
    function()
      if gold.total >= self.skills.price then
        self.skills.damage = self.skills.damage + 1
        self.skills.damPurch = self.skills.damPurch + 1
        self:purchase()
      end
    end,
      function()
      if gold.total >= self.skills.price then
        self.skills.reload = self.skills.reload + 1
        self.skills.reloadPurch = self.skills.reloadPurch + 1
        self:purchase()
      end
    end,
      function()
      if gold.total >= self.skills.price then
        self.skills.maxAmmo = self.skills.maxAmmo + 1
        self.skills.ammoPurch = self.skills.ammoPurch + 1
        self:purchase()
      end
    end,
    function()
      if gold.total >= self.skills.price then
        self.skills.speed = self.skills.speed + 20
        self.skills.speedPurch = self.skills.speedPurch + 1
        self:purchase()
      end
    end,
    function()
      if gold.total >= self.skills.price then
        self.skills.magnet = self.skills.magnet * 1.20
        self.skills.magPurch = self.skills.magPurch + 1
        self:purchase()
      end
    end,
    function()
      if gold.total >= self.skills.price and player.hp < player.maxHp then
        player:addHealth()
        self:purchase()
      end
    end
  }
end

function shop:update(dt)
  self.timer:update(dt)
  --Check if upgrades maxed out
  if not self.btnsCreated then return end
  for i=1,#self.buttons do
    local b = self.buttons[i]
    if not b then return end
    if b.clicked >= 20 then
      shopButtonManager.remove(i)
      self.buttons = shopButtonManager.getButtons()
    end
  end
end

function shop:draw()
  cam:zoomTo(6)
  cam:attach()
  local ret1,ret2 = cam:mousePosition()
  local origin,origin2,origin2Bot,originRight,originXCenter,originYCenter = cameraCoordinates(cam, 6)
  
  love.graphics.setShader(shopShader)
  mainMap:drawLayer(mainMap.layers["Background"])
  love.graphics.setShader()
  
  self:displayUI(origin,origin2,origin2Bot,originRight,originXCenter,originYCenter,ret1,ret2)
  
  cam:detach()
  cam:zoomTo(currentZoom.zoom)
end

function shop:enter(previous)
  if not self.game then self.game = previous end
end

local function uiBox(skill, x, y, num)
  if shop.skills[skill] < num then
    love.graphics.draw(shop.icons.unpurchased, x, y)
  elseif shop.skills[skill] >= num then
    love.graphics.draw(shop.icons.purchased, x, y)
  end
end

local function nextRound()
  if not shop.nextClicked then
    shop.nextClicked = true
    shop.timer:after(.1, function()
      shop.cooldown = false
      calcBonuses(shop.skills)
      
      soundFX.music:setVolume(.3)
      shop.nextClicked = false
      Gamestate.switch(shop.game)
    end)
  end
end

function shop:displayUI(origin,origin2,origin2Bot,originRight,originXCenter,originYCenter, ret1, ret2)
  --create buttons -- TODO: this code sucks dick balls and penis
  if not self.btnsCreated then
    for i=1,#self.purchases do
      local fn = self.purchases[i]
      if i == 1 then
        shopButtonManager.new(originXCenter - 105, origin2 + 60, fn, self.buttonSprite, self.buttonSpriteHot, 1, nil, soundFX.btnHover)
      elseif i == 2 then
        shopButtonManager.new(originXCenter - 105, origin2 + 90, fn, self.buttonSprite, self.buttonSpriteHot, 1, nil, soundFX.btnHover)
      elseif i == 3 then
        shopButtonManager.new(originXCenter - 105, origin2 + 120, fn, self.buttonSprite, self.buttonSpriteHot, 1, nil, soundFX.btnHover)
      elseif i == 4 then
        shopButtonManager.new(originXCenter - 105, origin2 + 150, fn, self.buttonSprite, self.buttonSpriteHot, 1, nil, soundFX.btnHover)
      elseif i == 5 then
        shopButtonManager.new(originXCenter - 105, origin2 + 180, fn, self.buttonSprite, self.buttonSpriteHot, 1, nil, soundFX.btnHover)
      elseif i == 6 then
        shopButtonManager.new(originXCenter + 22, origin2 + 155, fn, self.buttonSprite, self.buttonSpriteHot, 1, nil, soundFX.btnHover)
      end
      
      shopButtonManager.new(originXCenter + 56, origin2Bot - 40, nextRound, self.continue, self.continueHover, 1, soundFX.charSelect, soundFX.btnHover)
    end
    self.buttons = shopButtonManager.getButtons()
    self.btnsCreated = true
  end
  
  love.graphics.draw(self.display, originXCenter, originYCenter, nil, 1, 1, self.display:getWidth()/2, self.display:getHeight()/2)
  love.graphics.print("Current Price: "..self.skills.price, originXCenter - 110, origin2Bot - 17)
  
  if self.currentScreen == 1 then
    --UI Boxes--
    for i=1,5 do
      for j=1,20 do
        uiBox(self.skillList[i], origin + 114 + (j * 5), origin2 + 32 + (i * 30), j)
      end
    end
    
    shopButtonManager.draw(ret1, ret2)
    
    local iconXOff = 210
    local iconScale = 1.5
    love.graphics.print("Damage", origin + 110, origin2 + 50, nil, self.textScale, self.textScale)
    love.graphics.draw(self.icons.damage, origin + iconXOff, origin2 + 50, nil, iconScale, iconScale)
    
    love.graphics.print("Reload", origin + 110, origin2 + 80, nil, self.textScale, self.textScale)
    love.graphics.draw(self.icons.reload, origin + iconXOff, origin2 + 80, nil, iconScale, iconScale)
    
    love.graphics.print("Ammo", origin + 110, origin2 + 110, nil, self.textScale, self.textScale)
    love.graphics.draw(self.icons.ammo, origin + iconXOff, origin2 + 110, nil, iconScale, iconScale)
    
    love.graphics.print("Speed", origin + 110, origin2 + 140, nil, self.textScale, self.textScale)
    love.graphics.draw(self.icons.speed, origin + iconXOff, origin2 + 140, nil, iconScale, iconScale)
    
    love.graphics.print("Magnet", origin + 110, origin2 + 170, nil, self.textScale, self.textScale)
    love.graphics.draw(self.icons.magnet, origin + iconXOff, origin2 + 170, nil, iconScale, iconScale)
    
    
    --Current Health Display
    love.graphics.print("Health ( +25 )", originXCenter + 35, originYCenter + 37, nil, self.textScale, self.textScale)
    love.graphics.print("Current: " .. player.hp, originXCenter + 30, originYCenter + 58, nil, 1/3, 1/3)
    love.graphics.print("Max: 100", originXCenter + 65, originYCenter + 58, nil, 1/3, 1/3)
    love.graphics.draw(self.uiBox3, originXCenter + 30, originYCenter + 47, nil)
    --player.healthBar.animation:draw(player.healthBar.sprite, originXCenter + 29, originYCenter + 45, nil, 5, 5)
    love.graphics.draw(self.game.heartIcon, originXCenter + 33, originYCenter + 47, nil, nil, nil, 4)
  end
  
  --Continue Button
  love.graphics.print("Next Round", originXCenter + 61, origin2Bot - 36.5, nil, self.textScale, self.textScale)
  
  --Gold & Reticle
  love.graphics.printf(math.floor(gold.total), origin + 20, origin2 + 4, 100, "left")
  love.graphics.draw(gold.bigSprite, origin + 2, origin2 + 2)
  love.graphics.draw(reticle, ret1, ret2,nil,nil,nil,3,3)
end

function shop:leave()
  self.btnsCreated = false
  shopButtonManager.clear()
end

function shop:purchase()
  love.audio.stop(soundFX.makePurchase)
  love.audio.play(soundFX.makePurchase)
  gold.total = gold.total - self.skills.price
  self.skills.price = self.skills.price + 2
  self.skills.healthPrice = self.skills.price
end

function shop:reset()
  self.btnsCreated = false
  shopButtonManager.clear()
end

return shop