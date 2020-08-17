function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setMode(1920, 1080)
  pixelFont = love.graphics.newFont('sprites/Minecraft.ttf', 16)
  love.graphics.setFont(pixelFont)
  pixelFont:setFilter( "nearest", "nearest" )
  
  --loadingScreen(2)
  globalTimer = require('hump-master/timer')
  tween = require('tween-master/tween')
  anim8 = require('anim8-master/anim8')
  require('sounds')
  loadSoundFX()
  require('prompts')
  require('player')
  require('zombie')
  require('bullets')
  require('healthbar')
  require('rounds')
  require('shop')
  require('gold')
  require('gameCam')
  require('energy')
  require('gameOver')
  --require('particles')
  sti = require('SimpleTI/sti')
  
  spawnPlayerHealthBar()
  reticle = love.graphics.newImage('sprites/cursor.png')
  love.mouse.setVisible(false)
  
  currentPrompt = nil
  
  mainMap = sti('sprites/mainMap.lua')
end

function love.update(dt)
  
  updatePromptAlpha(dt)
  cameraHandler(player.x, player.y)
  playerUpdate(dt)
  walkAnimation(dt)
  zombieUpdate(dt)
  bulletUpdate(dt)
  updateRounds(dt)
  autoShoot(dt)
  updateGold(dt)
  energyUpdate(dt)
  --particleUpdate(dt)
  gameMusic(dt)
  
  if round.gameState == 2 then
    roundTimer:update(dt)
    if player.canDash == false then
      dashTimer:update(dt)
    end
  end
  
  mainMap:update(dt)
end

function love.draw()
  if round.gameState == 2 then
    cam:attach()
    mainMap:drawLayer(mainMap.layers["Background"])
    origin,origin2 = cam:worldCoords(0,0)
    
    player.animation:draw(player.sprite, player.x, player.y, player_angle(), 1, 1, player.frame:getWidth()/2, 1 + player.frame:getHeight()/2)
    
    for i,z in ipairs(zombies) do
      if z.damage == 10 then
        z.animation:draw(z.sprite, z.x, z.y, z.currentAngle+math.pi/2, 1.2, 1.2, 5, z.frame:getHeight()/2)
        if z.healthBar.isHidden == false then
          z.healthBar.animation:draw(z.healthBar.sprite, z.healthBar.x, z.healthBar.y, nil, .8, .8, 6, -5)
        end
      elseif z.damage == 25 then
        z.animation:draw(z.sprite, z.x, z.y, z.currentAngle+math.pi/2, 1.2, 1.2, z.frame:getWidth()/2, z.frame:getHeight()/2)
        if z.healthBar.isHidden == false then
          z.healthBar.animation:draw(z.healthBar.sprite, z.healthBar.x, z.healthBar.y, nil, 1.5, 1.5, 6, 8)
        end
      else
        z.animation:draw(z.sprite, z.x, z.y, z.currentAngle+math.pi/2, 1.2, 1.2, z.frame:getWidth()/2, z.frame:getHeight()/2)
        if z.healthBar.isHidden == false then
          z.healthBar.animation:draw(z.healthBar.sprite, z.healthBar.x, z.healthBar.y, nil, .8, .8, 7, 2)
        end
        --love.graphics.draw(z.p.pSystem, z.x, z.y, nil, 3, 3)
      end
    end
    
    for i,b in ipairs(bullets) do
      love.graphics.draw(b.sprite, b.x, b.y, b.direction, 1.2, 1.2, 3, 3)
    end
    
    for i,c in ipairs(coins) do
      if c.value ~= 2500 then
        love.graphics.draw(c.sprite, c.x, c.y, nil, nil, nil, 2, 2)
      else
        love.graphics.draw(c.sprite, c.x, c.y, nil, nil, nil, 2, 2)
      end
    end
    
    --draw prompts
    if currentPrompt == nil then
      currentPrompt = prompts.wasd
    end
    drawPrompt(currentPrompt, origin + 130, origin2 + 40, prompts.alpha.alpha)
    
    love.graphics.draw(round.uiBox3, origin, origin2 + 203)
    player.healthBar.animation:draw(player.healthBar.sprite, origin - 1, origin2 + 201, nil, 5, 5)
    
    love.graphics.draw(round.uiBox2, origin + 2, origin2 + 193)
    drawEnergy(origin + 4,origin2 + 196,energy.width,energy.height)
    
    love.graphics.printf(math.floor(gold.total), origin + 20, origin2 + 4, 100, "left")
    love.graphics.draw(gold.bigSprite, origin + 2, origin2 + 2)
    
    love.graphics.draw(round.uiBox, origin + 2, origin2 + 22)
    love.graphics.printf("Round", origin + 16, origin2 + 24, 100, "left", nil, .6, .6)
    
    love.graphics.draw(round.uiBox, origin + 2, origin2 + 38)
    love.graphics.printf(round.difficulty, origin + 28, origin2 + 40, 100, "left", nil, .6, .6)
    
    ret1,ret2 = cam:mousePosition()
    love.graphics.draw(reticle, ret1, ret2,nil,nil,nil,3,3)
    
    cam:detach()
  elseif round.gameState == 3 then
    displayShop()
  elseif round.gameState == 1 then
    gameOverScreen()
  end
end

function loadingScreen(s)
  love.graphics.clear()
  love.graphics.draw(love.graphics.newImage('sprites/mainMap.png'))
  love.graphics.printf("Loading...", love.graphics.getWidth()/2, love.graphics.getHeight()-100, 10000, "left", nil, 5, 5, 30)
  love.graphics.present()
  love.timer.sleep(s) -- simulates 1 second load time
end

function player_angle()
  local a,b = cam:cameraCoords(cam:mousePosition())
  local c,d = cam:cameraCoords(player.x, player.y)
  return math.atan2(d - b, c - a) - math.pi/2
end

function zombie_angle(enemy)
  local a,b = cam:cameraCoords(enemy.x, enemy.y)
  local c,d = cam:cameraCoords(player.x, player.y)
  return math.atan2(d - b, c - a) + math.pi/2
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

function linInterp(min,max,fraction)
  return ((max - min) * fraction + min)
end