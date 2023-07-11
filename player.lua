local PlayerParticleManager = require('particleManager')
local Characters = require('dicts/characterDict')

local dashSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
dashSystem:setParticleLifetime (.05, .3)
dashSystem:setSizes(1)
dashSystem:setSpeed(60)


local sprite = love.graphics.newImage('sprites/characters/chrome.png')
player = HC.rectangle(map_width / 2, map_height / 2, sprite:getWidth() * .75, sprite:getHeight() * .75)
player.zoom = 4

--powerups
player.isInvincible = false
player.damageUp = false

player.isPlayer = true
player.sprite = love.graphics.newImage('sprites/characters/chromeWalk.png')
player.frame = love.graphics.newImage('sprites/characters/chrome.png')
player.x = map_width / 2
player.vx = 0
player.y = map_height / 2
player.vy = 0
player.w = player.frame:getWidth()
player.h = player.frame:getHeight()
player.v = 470
player.bonusV = 0
player.friction = 8
player.grid = anim8.newGrid(16, 16, 128, 16)
player.animation = anim8.newAnimation(player.grid("1-8",1), 0.08)
player.health = 100
player.barSprite = love.graphics.newImage('sprites/healthbarUI.png')
player.heartIcon = love.graphics.newImage('sprites/heartIcon.png')
player.ammoIcon = love.graphics.newImage('sprites/energyIcon.png')
player.canDash = true
player.dashP = PlayerParticleManager.new(player.x, player.y, dashSystem:clone(), 1)
player.isRecharge = true

function player:keybinds(key, upgradeSpeed)
  if key == 'space' then
    if player.canDash == true then
      
      love.audio.play(soundFX.dash)
      PlayerParticleManager.spawn(player.dashP.psys, math.random(12,24), 0, math.pi*2, 1)
      player.canDash = false
      player.isRecharge = false
      
      if love.keyboard.isDown("a") then
        player.vx = player.vx - (player.v+upgradeSpeed)/2
      end
      if love.keyboard.isDown("d") then
        player.vx = player.vx + (player.v+upgradeSpeed)/2
      end
      if love.keyboard.isDown("w") then
        player.vy = player.vy - (player.v+upgradeSpeed)/2
      end
      if love.keyboard.isDown("s") then
        player.vy = player.vy + (player.v+upgradeSpeed)/2
      end
      dashTween:reset()
    end
  end
end

function spawnPlayerHealthBar()
  player.healthBar = {}
  table.insert(player, spawnHealthBar(player.health, player.x, player.y, player.healthBar))
  player.healthBar.sprite = player.barSprite
end

function drawPlayer()
  player.animation:draw(player.sprite, player.x, player.y, player_angle(), 1, 1, player.w/2, 1 + player.h/2)
  PlayerParticleManager.draw(player.dashP.psys, player.x, player.y)
end

function playerUpdate(dt, upgradeSpeed, game)
  PlayerParticleManager.update(player.dashP.psys, dt)
  walkAnimation(dt)
  
  healthBarUpdate(player.x, player.y, player.healthBar, player.healthBar.animation, player.health, player.healthBar.totalHealth)
  if player.health <= 0 then
    Gamestate.switch(game.menu)
  end
  movementHandle(dt, upgradeSpeed, game)
end

function walkAnimation(dt)
  if love.keyboard.isDown('w','a','s','d') then
    player.animation:update(dt)
    soundFX.move:resume()
  else
    player.animation:gotoFrame(1)
    love.audio.pause(soundFX.move)
  end
end

local playerFilter = function(item, other)
  if other.isBullet then return nil
  elseif other.isZombie then return 'cross'
  end
end

function movementHandle(dt, speedUpgrade, game)
  local penalty = 0
  if love.mouse.isDown(1) and guns.equipped.tween and canShoot then
    penalty = guns.equipped.movementPenalty
    guns.equipped.tween:update(dt)
    guns.equipped.animation:update(dt/guns.equipped.frameTime.v)
  elseif guns.equipped.tween then
    guns.equipped.tween:reset()
  end
  
  if love.keyboard.isDown("a") then
    player.vx = player.vx - (player.v+speedUpgrade+player.bonusV-penalty)*dt
  end
  if love.keyboard.isDown("d") then
    player.vx = player.vx + (player.v+speedUpgrade+player.bonusV-penalty)*dt
  end
  if love.keyboard.isDown("w") then
    player.vy = player.vy - (player.v+speedUpgrade+player.bonusV-penalty)*dt
  end
  if love.keyboard.isDown("s") then
    player.vy = player.vy + (player.v+speedUpgrade+player.bonusV-penalty)*dt
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
  local collisions = HC.collisions(player)
  for other, separating_vector in pairs(collisions) do
    --zombie
    if other.parent.isZombie then
      local collides, dx, dy = player:collidesWith(other)
      if collides and other.parent.collideable then
        collideWithZombie(other.parent, game)
      end
    end
    
    --bullet
    if other.parent.isBullet then
      local collides, dx, dy = player:collidesWith(other)
      if collides and other.parent.isEnemyBullet and not other.parent.dead then
        collideBulletWithPlayer(other.parent, game)
      end
    end
  end

  local goalX = player.x + player.vx * dt
  local goalY = player.y + player.vy * dt
  player.x = goalX
  player.y = goalY
  
  player:moveTo(goalX,goalY)
  player:setRotation(player_angle())
end

dashTimer = globalTimer.new()
dashTimer:every(2.7, function()
  player.canDash = true
  player.isRecharge = true
end)

function collideBulletWithPlayer(b, game)
  --Damage
  player.health = player.health - b.damage
  game.textManager.playerDmgPopup(player.x, player.y, b)
  shaders.damaged = true
  shaderTimer:after(.1, function() shaders.damaged = false end)
  
  love.audio.play(soundFX.player_hit)

  b.dead = true
end

function collideWithZombie(zom, game)
  zom.dead = true
  zom.collideable = false
  if not player.isInvincible then
    player.health = player.health - zom.damage
    love.audio.play(soundFX.player_hit)
    game.textManager.playerDmgPopup(player.x, player.y, zom)
    screenShake(.15, 1)
    shaders.damaged = true
    shaderTimer:after(.15, function() shaders.damaged = false end)
  else
    spawnGoldReward(zom)
    spawnXPReward(zom)
  end
  game.currentKilled = game.currentKilled + 1
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