shop = {}

shop.sprite = love.graphics.newImage('sprites/shop.png')
shop.x = 0
shop.y = 0
shop.skills = {}
shop.skills.price = 5
shop.skills.healthPrice = 5
shop.skills.damage = 0
shop.skills.pierce = 0
shop.skills.defense = 0
shop.skills.speed = 0
shop.skills.bulletSpeed = 0
shop.skills.fireRate = 1

function displayShop()
  love.graphics.draw(shop.sprite, shop.x, shop.y, nil, 4, 4)
  love.graphics.print("Gold:  "..math.floor(gold.total), love.graphics.getWidth()/2, 250, nil, 4, 4, 25)
  love.graphics.print("Skill Price:  "..math.ceil(shop.skills.price), love.graphics.getWidth()/2, 350, nil, 4, 4, 25)
  love.graphics.print("Health Price:  "..math.floor(shop.skills.healthPrice), love.graphics.getWidth()/2, 450, nil, 4, 4, 25)
  love.graphics.print("Damage:  "..shop.skills.damage .."\n\nSpeed:  "..shop.skills.speed .."\n\nFire Rate:  ".. math.ceil(shop.skills.fireRate*1000)/10 .."%", 0, 200, nil, 4, 4)
  love.graphics.print("Press B to purchase Health.\nPress Z,X, or C to purchase skills.", 4, 650, nil, 4, 4)
end