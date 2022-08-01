local shopButtonManager = require('buttonManager')

shop = {}
shop.currentScreen = 1 --general tab 
local shopButtonsCreated = false
local shopButtons = nil
local shopTimer = globalTimer.new()
local nextClicked = false
shopCooldown = false

shop.buttonSprite = love.graphics.newImage('sprites/ui/shopButton.png')
shop.buttonSpriteHot = love.graphics.newImage('sprites/ui/shopButtonHot.png')
shop.continue = love.graphics.newImage('sprites/ui/UIBox1.png')
shop.continueHover = love.graphics.newImage('sprites/ui/UIBox1Hover.png')

shop.display = love.graphics.newImage('sprites/ui/UIShop.png')
shop.textScale = 1/2
shop.x = 0
shop.y = 0
shop.skills = {}
shop.skills.price = 10
shop.skills.grenades = 100
shop.skills.damage = 6
shop.skills.damPurch = 0
shop.skills.speedPurch = 0
shop.skills.ratePurch = 0
shop.skills.magPurch = 0
shop.skills.ammoPurch = 0
shop.skills.maxAmmo = 6
shop.skills.reload = 2.5
shop.skills.speed = 0
shop.skills.magnet = 1
shop.rate = 1

--define functions for purchasing skills
skills = {
  function()
    if gold.total >= shop.skills.price then
      shop.skills.damage = shop.skills.damage + 2
      shop.skills.damPurch = shop.skills.damPurch + 1
      purchase()
    end
  end,
  function()
    if gold.total >= shop.skills.price then
      shop.skills.speed = shop.skills.speed + 10
      shop.skills.speedPurch = shop.skills.speedPurch + 1
      purchase()
    end
  end,
  function()
    if gold.total >= shop.skills.price then
      shop.skills.reload = shop.skills.reload * .98
      updateTweens()
      shop.skills.ratePurch = shop.skills.ratePurch + 1
      purchase()
    end
  end,
  function()
    if gold.total >= shop.skills.price then
      shop.skills.magnet = shop.skills.magnet * 1.05
      shop.skills.magPurch = shop.skills.magPurch + 1
      purchase()
    end
  end,
  function()
    if gold.total >= shop.skills.price then
      shop.skills.maxAmmo = shop.skills.maxAmmo + 2
      shop.skills.ammoPurch = shop.skills.ammoPurch + 1
      purchase()
    end
  end,
  function()
    if gold.total >= shop.skills.price and player.health < player.healthBar.totalHealth then
      addPurchasedHealth()
      purchase()
    end
  end
}

function shopUpdate(dt)
  shopTimer:update(dt)
  --Check if upgrades maxed out
  if not shopButtonsCreated then return end
  for i=1,#shopButtons do
    local b = shopButtons[i]
    if not b then return end
    if b.clicked >= 5 then
      shopButtonManager.remove(i)
      shopButtons = shopButtonManager.getButtons()
    end
  end
end

function nextRound()
  if not nextClicked then
    nextClicked = true
    shopTimer:after(.1, function()
      shopCooldown = false
      round.zombiesMaxSpawn = math.floor(math.random(5,8)) + round.difficulty
      resetShopButtons()
      round.difficulty = round.difficulty + 1
      round.gameState = 2
      soundFX.music:setVolume(.3)
      nextClicked = false
    end)
    love.audio.play(soundFX.roundStart)
  end
end

function generalTab()
  
end

function displayShop(origin,origin2,origin2Bot,originRight,originXCenter,originYCenter, ret1, ret2)
  --create buttons -- TODO: this code sucks dick balls
  if not shopButtonsCreated then
    for i=1,#skills do
      local fn = skills[i]
      if i == 1 then
        shopButtonManager.new(originXCenter - 90, originYCenter - 70, fn, shop.buttonSprite, shop.buttonSpriteHot)
      elseif i == 2 then
        shopButtonManager.new(originXCenter - 90, originYCenter - 35, fn, shop.buttonSprite, shop.buttonSpriteHot)
      elseif i == 3 then
        shopButtonManager.new(originXCenter - 90, originYCenter, fn, shop.buttonSprite, shop.buttonSpriteHot)
      elseif i == 4 then
        shopButtonManager.new(originXCenter - 90, originYCenter + 35, fn, shop.buttonSprite, shop.buttonSpriteHot)
      elseif i == 5 then
        shopButtonManager.new(originXCenter + 20, originYCenter - 70, fn, shop.buttonSprite, shop.buttonSpriteHot)
      elseif i == 6 then
        shopButtonManager.new(originXCenter + 20, originYCenter + 35, fn, shop.buttonSprite, shop.buttonSpriteHot)
      end
      
      shopButtonManager.new(originXCenter + 56, origin2Bot - 40, nextRound, shop.continue, shop.continueHover)
      
      shopButtonManager.new(origin + 50, origin2 + 45, generalTab, shop.continue, shop.continueHover)
      shopButtonManager.new(origin + 50, origin2 + 58, pistolTab, shop.continue, shop.continueHover)
      shopButtonManager.new(origin + 50, origin2 + 71, shotgunTab, shop.continue, shop.continueHover)
      shopButtonManager.new(origin + 50, origin2 + 84, sniperTab, shop.continue, shop.continueHover)
      shopButtonManager.new(origin + 50, origin2 + 97, uziTab, shop.continue, shop.continueHover)
    end
    shopButtons = shopButtonManager.getButtons()
    shopButtonsCreated = true
  end
  
  love.graphics.draw(shop.display, originXCenter, originYCenter, nil, 1, 1, shop.display:getWidth()/2, shop.display:getHeight()/2)
  love.graphics.print("Current Price: "..shop.skills.price, originXCenter - 110, origin2Bot - 17)
  
  if shop.currentScreen == 1 then
    shopButtonManager.draw(ret1, ret2)
  
    --Stats
    love.graphics.printf(shop.skills.damPurch, originXCenter - 145, originYCenter - 70, 100, "right", nil, shop.textScale, shop.textScale)
    love.graphics.printf(shop.skills.speedPurch, originXCenter - 145, originYCenter - 35, 100, "right", nil, shop.textScale, shop.textScale)
    love.graphics.printf(shop.skills.ratePurch, originXCenter - 145, originYCenter, 100, "right", nil, shop.textScale, shop.textScale)
    love.graphics.printf(shop.skills.magPurch, originXCenter - 145, originYCenter + 35, 100, "right", nil, shop.textScale, shop.textScale)
    
    love.graphics.print("Damage ( +2 )", originXCenter - 75, originYCenter - 68, nil, shop.textScale, shop.textScale)
    love.graphics.print("Speed ( +10 )", originXCenter - 75, originYCenter - 33, nil, shop.textScale, shop.textScale)
    love.graphics.print("Reload ( -2% )", originXCenter - 75, originYCenter + 2, nil, shop.textScale, shop.textScale)
    love.graphics.print("Magnet ( +10% )", originXCenter - 75, originYCenter + 37, nil, shop.textScale, shop.textScale)
    
    love.graphics.print("Current: ".. shop.skills.damage, originXCenter - 75, originYCenter - 58, nil, 1/3, 1/3)
    love.graphics.print("Current: ".. math.floor(shop.skills.speed + player.v), originXCenter - 75, originYCenter - 23, nil, 1/3, 1/3)
    love.graphics.print("Current: ".. tonumber(string.format("%.2f", shop.skills.reload)).. "s", originXCenter - 75, originYCenter + 12, nil, 1/3, 1/3)
    love.graphics.print("Current: ".. tonumber(string.format("%.2f", shop.skills.magnet)).. "x Multiplier", originXCenter - 75, originYCenter + 47, nil, 1/3, 1/3)
    
    --Stats Row 2
    love.graphics.printf(shop.skills.ammoPurch, originXCenter - 35, originYCenter - 70, 100, "right", nil, shop.textScale, shop.textScale)
    love.graphics.print("Max Ammo ( +2 )", originXCenter + 35, originYCenter - 68, nil, shop.textScale, shop.textScale)
    love.graphics.print("Current: ".. shop.skills.maxAmmo, originXCenter + 35, originYCenter - 58, nil, 1/3, 1/3)
    
    --Current Health Display
    love.graphics.print("Health ( +25 )", originXCenter + 35, originYCenter + 37, nil, shop.textScale, shop.textScale)
    love.graphics.print("Current: " .. player.health, originXCenter + 30, originYCenter + 58, nil, 1/3, 1/3)
    love.graphics.print("Max: 100", originXCenter + 65, originYCenter + 58, nil, 1/3, 1/3)
    love.graphics.draw(round.uiBox3, originXCenter + 30, originYCenter + 47, nil)
    player.healthBar.animation:draw(player.healthBar.sprite, originXCenter + 29, originYCenter + 45, nil, 5, 5)
    love.graphics.draw(player.heartIcon, originXCenter + 33, originYCenter + 47, nil, nil, nil, 4)
  end
  
  --Continue Button
  love.graphics.print("Next Round", originXCenter + 61, origin2Bot - 36.5, nil, shop.textScale, shop.textScale)
  
  --Gold & Reticle
  love.graphics.printf(math.floor(gold.total), origin + 20, origin2 + 4, 100, "left")
  love.graphics.draw(gold.bigSprite, origin + 2, origin2 + 2)
  love.graphics.draw(reticle, ret1, ret2,nil,nil,nil,3,3)
end

function resetShopButtons()
  shopButtonsCreated = false
  shopButtonManager.clear()
end

function purchase()
  love.audio.stop(soundFX.makePurchase)
  love.audio.play(soundFX.makePurchase)
  gold.total = gold.total - shop.skills.price
  shop.skills.price = shop.skills.price + 2
  shop.skills.healthPrice = shop.skills.price
end

function resetShop()
  resetShopButtons()
  shop.skills.price = 10
  shop.skills.grenades = 10
  shop.skills.damage = 6
  shop.skills.damPurch = 0
  shop.skills.speedPurch = 0
  shop.skills.ratePurch = 0
  shop.skills.magPurch = 0
  shop.skills.ammoPurch = 0
  shop.skills.maxAmmo = 6
  shop.skills.reload = 2.5
  shop.skills.speed = 0
  shop.skills.magnet = 1
  shop.rate = 1
end