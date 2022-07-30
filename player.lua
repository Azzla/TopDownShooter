player = {}

--powerups
player.isInvincible = false
player.damageUp = false

player.isPlayer = true
player.sprite = love.graphics.newImage('sprites/robotWalk.png')
player.frame = love.graphics.newImage('sprites/Robot.png')
player.x = map_width / 2
player.vx = 0
player.y = map_height / 2
player.vy = 0
player.w = player.frame:getWidth()
player.h = player.frame:getHeight()
player.v = 350
player.friction = 6
player.grid = anim8.newGrid(16, 16, 128, 16)
player.animation = anim8.newAnimation(player.grid("1-8",1), 0.08)
player.health = 100
player.barSprite = love.graphics.newImage('sprites/healthbarUI.png')
player.heartIcon = love.graphics.newImage('sprites/heartIcon.png')
player.ammoIcon = love.graphics.newImage('sprites/energyIcon.png')
player.canDash = true
player.p = spawnBulletParticleSystem(player.x, player.y)
player.dashP = spawnDashParticleSystem(player.x, player.y)
player.isRecharge = true

world:add(player, player.x - (player.w/2 * .8), player.y - (player.h/2 * .8), player.w * .8, player.h * .8)

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
      soundFX.move:resume()
    else
      player.animation:gotoFrame(1)
      love.audio.pause(soundFX.move)
    end
  elseif round.gameState == 3 then
    love.audio.pause(soundFX.move)
  end
end

local playerFilter = function(item, other)
  if other.isBullet then return nil
  elseif other.isZombie then return 'cross'
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
  
  if player.x <= 10 then
    player.vx = player.vx * -1
    player.x = player.x + 1
  end
  if player.y <= 10 then
    player.vy = player.vy * -1
    player.y = player.y + 1
  end
  if player.x >= map_width - 10 then
    player.vx = player.vx * -1
    player.x = player.x - 1
  end
  if player.y >= map_height - 10 then
    player.vy = player.vy * -1
    player.y = player.y - 1
  end
  
  player.vx = player.vx * (1 - math.min(dt*player.friction, .5))
  player.vy = player.vy * (1 - math.min(dt*player.friction, .5))
  
  --Collisions--
  local goalX = player.x + player.vx * dt
  local goalY = player.y + player.vy * dt
  local actualX, actualY, cols, length = world:move(player, goalX - (player.w/2 * .8), goalY - (player.h/2 * .8), playerFilter)
  player.x = actualX + (player.w/2 * .8)
  player.y = actualY + (player.h/2 * .8)
  
  for i=1,length do
    local other = cols[i].other
    if other.isZombie then
      collideWithZombie(other)
    end
  end
end

dashTimer = globalTimer.new()
dashTimer:every(2.7, function()
  player.canDash = true
  player.isRecharge = true
end)

function collideWithZombie(zom)
  zom.dead = true
  zom.collideable = false
  if not player.isInvincible then
    player.health = player.health - zom.damage
    TextManager.playerDmgPopup(player.x, player.y, zom)
    screenShake(.15, 1)
    shaders.damaged = true
    shaderTimer:after(.15, function() shaders.damaged = false end)
  else
    spawnKillReward(zom)
  end
  round.currentKilled = round.currentKilled + 1
end

--TODO - im a trash programmer
function addPurchasedHealth()
  player.health = player.health + 25
  if player.health > 100 then player.health = 100 end
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