player = {}

player.x = love.graphics.getWidth()/2 - 400
player.vx = 0
player.y = love.graphics.getHeight()/2
player.vy = 0
player.v = 380
player.friction = 6
player.sprite = love.graphics.newImage('sprites/robotWalk.png')
player.frame = love.graphics.newImage('sprites/Robot.png')
player.grid = anim8.newGrid(16, 16, 128, 16)
player.animation = anim8.newAnimation(player.grid("1-8",1), 0.08)
player.health = 100
player.barSprite = love.graphics.newImage('sprites/healthbarUI.png')
player.canDash = true
player.melee = {}
player.melee.sprite = love.graphics.newImage('sprites/melee.png')
player.melee.range = 10
player.melee.damage = 20

function spawnPlayerHealthBar()
  player.healthBar = {}
  table.insert(player, spawnHealthBar(player.health, player.x, player.y, player.healthBar))
  player.healthBar.sprite = player.barSprite
end

function playerUpdate(dt)
  healthBarUpdate(player.x, player.y, player.healthBar, player.healthBar.animation, player.health, player.healthBar.totalHealth)
  if player.health <= 0 then
    round.gameState = 1
  end
  if round.gameState == 2 then
    movementHandle(dt)
  end
end

function walkAnimation(dt)
  if round.gameState == 2 then
    if love.keyboard.isDown('w','a','s','d') then
      player.animation:update(dt)
      love.audio.play(soundFX.move)
    else
      player.animation:gotoFrame(1)
      love.audio.pause(soundFX.move)
    end
  elseif round.gameState == 3 then
    love.audio.pause(soundFX.move)
  end
end

function movementHandle(dt)
  if love.keyboard.isDown("a") then
    player.vx = player.vx - (player.v+shop.skills.speed)*dt
  end
  if love.keyboard.isDown("d") then
    player.vx = player.vx + (player.v+shop.skills.speed)*dt
  end
  if love.keyboard.isDown("w") then
    player.vy = player.vy - (player.v+shop.skills.speed)*dt
  end
  if love.keyboard.isDown("s") then
    player.vy = player.vy + (player.v+shop.skills.speed)*dt
  end
  
  if player.x <= 6 then
    player.vx = player.vx * -1
    player.x = player.x + 1
  end
  if player.y <= 6 then
    player.vy = player.vy * -1
    player.y = player.y + 1
  end
  if player.x >= 1914 then
    player.vx = player.vx * -1
    player.x = player.x - 1
  end
  if player.y >= 1074 then
    player.vy = player.vy * -1
    player.y = player.y - 1
  end
  
  player.vx = player.vx * (1 - math.min(dt*player.friction, .5))
  player.vy = player.vy * (1 - math.min(dt*player.friction, .5))
  player.x = player.x + player.vx * dt
  player.y = player.y + player.vy * dt
end

dashTimer = globalTimer.new()
dashTimer:every(2.7, function() player.canDash = true end)

function addPurchasedHealth()
  player.health = player.health + .25*player.healthBar.totalHealth
  if player.health >= player.healthBar.totalHealth then
    player.healthBar.animation:gotoFrame(11)
  elseif player.health >= .89*player.healthBar.totalHealth then
    player.healthBar.animation:gotoFrame(10)
  elseif player.health >= .79*player.healthBar.totalHealth then
    player.healthBar.animation:gotoFrame(9)
  elseif player.health >= .69*player.healthBar.totalHealth then
    player.healthBar.animation:gotoFrame(8)
  elseif player.health >= .59*player.healthBar.totalHealth then
    player.healthBar.animation:gotoFrame(7)
  elseif player.health >= .49*player.healthBar.totalHealth then
    player.healthBar.animation:gotoFrame(6)
  elseif player.health >= .39*player.healthBar.totalHealth then
    player.healthBar.animation:gotoFrame(5)
  elseif player.health >= .29*player.healthBar.totalHealth then
    player.healthBar.animation:gotoFrame(4)
  elseif player.health >= .19*player.healthBar.totalHealth then
    player.healthBar.animation:gotoFrame(3)
  elseif player.health <= .9*player.healthBar.totalHealth and player.health > 0 then
    player.healthBar.animation:gotoFrame(2)
  elseif player.health <= 0 then
    player.healthBar.animation:gotoFrame(1)
  end
end