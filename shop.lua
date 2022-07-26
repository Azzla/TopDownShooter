shop = {}
shopButtons = {}
shopButtonsCreated = false

shop.buttonSprite = love.graphics.newImage('sprites/shopButton.png')
shop.buttonSpriteHot = love.graphics.newImage('sprites/shopButtonHot.png')
shop.display = love.graphics.newImage('sprites/UIShop.png')
shop.textScale = 1/2
shop.x = 0
shop.y = 0
shop.skills = {}
shop.skills.price = 10
shop.skills.grenades = 10
shop.skills.damage = 6
shop.skills.damPurch = 0
shop.skills.speedPurch = 0
shop.skills.ratePurch = 0
shop.skills.magPurch = 0
shop.skills.ammoPurch = 0
shop.skills.pierce = 0
shop.skills.defense = 0
shop.skills.maxAmmo = 6
shop.skills.reload = 2.5
shop.skills.speed = 0
shop.skills.bulletSpeed = 0
shop.skills.magnet = 1
shop.rate = 1

shop.rocketsPurchased = 0

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

function displayShop()
  love.graphics.draw(shop.display, originXCenter, originYCenter, nil, 1, 1, shop.display:getWidth()/2, shop.display:getHeight()/2)
  love.graphics.print("Current Price: "..shop.skills.price, originXCenter - 110, origin2Bot - 17)
  
  --Buttons
  drawShopButtons()
  
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
  
  --Gold & Reticle
  love.graphics.printf(math.floor(gold.total), origin + 20, origin2 + 4, 100, "left")
  love.graphics.draw(gold.bigSprite, origin + 2, origin2 + 2)
  love.graphics.draw(reticle, ret1, ret2,nil,nil,nil,3,3)
end

function resetShopButtons()
  shopButtonsCreated = false
  shopButtons = {}
end

function purchase()
  if soundFX.makePurchase:isPlaying() == true then
    love.audio.stop(soundFX.makePurchase)
  end
  love.audio.play(soundFX.makePurchase)
  gold.total = gold.total - shop.skills.price
  shop.skills.price = shop.skills.price + 2
  shop.skills.healthPrice = shop.skills.price
end

function newShopButton(x, y, fn)
  local button = {}
  button.x = x
  button.y = y
  button.sprite = shop.buttonSprite
  button.spriteHot = shop.buttonSpriteHot
  button.fn = fn
  
  table.insert(shopButtons, button)
end


function drawShopButtons()
  for i, button in ipairs(shopButtons) do
    button.last = button.now
    
    
    --check if hovering
    local isHot = ret1 > button.x and ret1 < button.x + button.sprite:getWidth() and 
                  ret2 > button.y and ret2 < button.y + button.sprite:getHeight()
    --draw sprite
    if isHot then
      love.graphics.draw(button.spriteHot, button.x, button.y)
    else
      love.graphics.draw(button.sprite, button.x, button.y)
    end
    --check for click
    if love.mouse.isDown(1) and not oldmousedown and isHot then
      button.fn()
    end
  end
  oldmousedown = love.mouse.isDown(1)
end

function resetShop()
  shop.skills.price = 10
  shop.skills.grenades = 10
  shop.skills.damage = 6
  shop.skills.damPurch = 0
  shop.skills.speedPurch = 0
  shop.skills.ratePurch = 0
  shop.skills.magPurch = 0
  shop.skills.ammoPurch = 0
  shop.skills.pierce = 0
  shop.skills.defense = 0
  shop.skills.maxAmmo = 6
  shop.skills.reload = 2.5
  shop.skills.speed = 0
  shop.skills.bulletSpeed = 0
  shop.skills.magnet = 1
  shop.rate = 1
end