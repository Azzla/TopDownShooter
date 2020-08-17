shop = {}

shop.sprite = love.graphics.newImage('sprites/shop.png')
shop.x = 0
shop.y = 0
shop.skills = {}
shop.skills.price = 10
shop.skills.healthPrice = 10
shop.skills.damage = 0
shop.skills.damPurch = 0
shop.skills.speedPurch = 0
shop.skills.ratePurch = 0
shop.skills.magPurch = 0
shop.skills.pierce = 0
shop.skills.defense = 0
shop.skills.speed = 0
shop.skills.bulletSpeed = 0
shop.skills.fireRate = 1
shop.skills.magnet = 1
shop.rate = 1

function displayShop()
  love.graphics.draw(shop.sprite, shop.x, shop.y, nil, 4, 4)
  love.graphics.print("Current Price: "..math.ceil(shop.skills.price), love.graphics.getWidth()/2 - 100, 350, nil, 4, 4)
  --love.graphics.print("Health Price: "..math.ceil(shop.skills.healthPrice), love.graphics.getWidth()/2 - 100, 450, nil, 4, 4)
  
  love.graphics.draw(round.uiBox3, love.graphics.getWidth()/2 + 5, love.graphics.getHeight()/2 + 10, nil, 5, 5)
  player.healthBar.animation:draw(player.healthBar.sprite, love.graphics.getWidth()/2, love.graphics.getHeight()/2, nil, 25, 25)
  
  love.graphics.print(shop.skills.damPurch, 600, 300, nil, 5, 5)
  love.graphics.print(shop.skills.speedPurch, 600, 560, nil, 5, 5)
  love.graphics.print(shop.skills.ratePurch, 600, 820, nil, 5, 5)
  love.graphics.print(shop.skills.magPurch, 600, 1030, nil, 5, 5)
    
  love.graphics.print("H to restore 25% of your maximum health.", love.graphics.getWidth()/2 - 200, 650, nil, 3, 3)
  
  love.graphics.draw(gold.bigSprite, 140, 15, nil, 5, 5)
  love.graphics.printf(math.floor(gold.total), 240, 25, 100, "left", nil, 5, 5)
  love.graphics.draw(reticle, love.mouse:getX(), love.mouse:getY(),nil,4,4,3,3)
end

function resetShop()
  shop.skills.price = 10
  shop.skills.healthPrice = 10
  shop.skills.damage = 0
  shop.skills.pierce = 0
  shop.skills.defense = 0
  shop.skills.speed = 0
  shop.skills.bulletSpeed = 0
  shop.skills.fireRate = 1
  shop.skills.magnet = 1 
  shop.skills.damPurch = 0
  shop.skills.speedPurch = 0
  shop.skills.ratePurch = 0
  shop.skills.magPurch = 0
  shop.rate = 1
end