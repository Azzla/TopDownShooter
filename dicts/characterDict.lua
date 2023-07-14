local characters = {}

characters.iron = {
  sprite = love.graphics.newImage('sprites/characters/iron.png'),
  spriteWalk = love.graphics.newImage('sprites/characters/ironWalk.png'),
  hp = 250,
  armor = 7,
  dmg = 5,
  v = 350,
  bonusV = 0,
  friction = 9,
  canDash = false
}

characters.chrome = {
  sprite = love.graphics.newImage('sprites/characters/chrome.png'),
  spriteWalk = love.graphics.newImage('sprites/characters/chromeWalk.png'),
  hp = 120,
  armor = 3,
  dmg = 7,
  v = 480,
  bonusV = 0,
  friction = 8,
  canDash = true,
  dashCooldown = 2.5,
  isRecharge = true
}

characters.osmium = {
  sprite = love.graphics.newImage('sprites/characters/osmium.png'),
  spriteWalk = love.graphics.newImage('sprites/characters/osmiumWalk.png'),
  hp = 250,
  armor = 7,
  dmg = 5,
  v = 350,
  bonusV = 0,
  friction = 9,
  canDash = false
}

characters.titanium = {
  sprite = love.graphics.newImage('sprites/characters/titanium.png'),
  spriteWalk = love.graphics.newImage('sprites/characters/titaniumWalk.png'),
  hp = 120,
  armor = 3,
  dmg = 7,
  v = 480,
  bonusV = 0,
  friction = 8,
  canDash = true,
  dashCooldown = 2.5,
  isRecharge = true
}

characters[1] = characters.iron
characters[2] = characters.chrome
characters[3] = characters.osmium
characters[4] = characters.titanium

return characters