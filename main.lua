function love.load()
  KEYPRESSED={}
  
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  love.window.setMode(0, 0)
  --love.window.setMode(1920, 1080)
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
  zoom_factor = 6
--  if screen_height >= 1440 then zoom_factor = 6 end
  love.window.setFullscreen(true, "desktop")
  
  --font
  pixelFont = love.graphics.newFont('sprites/Minecraft.ttf', 16)
  love.graphics.setFont(pixelFont)
  pixelFont:setFilter( "nearest", "nearest" )
  
  --map
  sti = require('SimpleTI/sti')
  mainMap = sti('sprites/mainMapV2.lua')
  map_width = mainMap.width * mainMap.tilewidth
  map_height = mainMap.height * mainMap.tileheight
  
  --loadingScreen(2)
  globalTimer = require('hump-master/timer')
  tween = require('tween-master/tween')
  anim8 = require('anim8-master/anim8')
  
  Class = require('floating-text-master/class')
  require('floating-text-master/effects/PopupText')
  require('floating-text-master/effects/PopupTextManager')
  gPopupManager = PopupTextManager()
  
  bump = require('bump-master/bump')
  --collision world
  world = bump.newWorld(32)
  
  require('shaders')
  require('sounds')
  loadSoundFX()
  require('menu')
  require('prompts')
  require('particles')
  require('guns')
  require('player')
  require('zombie')
  require('bullets')
  require('grenades')
  require('healthbar')
  require('rounds')
  require('shop')
  require('gold')
  require('gameCam')
  require('energy')
  require('gameOver')
  require('powerups')
  
  spawnPlayerHealthBar()
  nightCycle()
  reticle = love.graphics.newImage('sprites/cursor.png')
  love.mouse.setVisible(false)
  currentPrompt = nil
  pausedAngle = nil
end

function love.update(dt)
  gameMusic(dt)
  if round.gameState == 4 then
    globalTimer.update(dt)
  end
  if round.gameState == 2 then
    gPopupManager:update(dt)
    updatePromptAlpha(dt)
    updateShaderTimers(dt)
    updateCameraTimers(dt)
    cameraHandler(player.x, player.y, dt)
    playerUpdate(dt)
    walkAnimation(dt)
    zombieUpdate(dt)
    bulletUpdate(dt)
    grenadeUpdate(dt)
    updateRounds(dt)
    updateGold(dt)
    energyUpdate(dt)
    particleUpdate(dt)
    powerupUpdate(dt)
    roundTimer:update(dt)
    mainMap:update(dt)
    if player.canDash == false then
      dashTimer:update(dt)
    end
  end
end

function love.draw()
  if round.gameState == 4 then
    mainMenu()
  elseif round.gameState == 6 then
    helpScreen()
  elseif round.gameState == 2 then
    resetShopButtons()
    cam:zoomTo(currentZoom.zoom)
    cam:attach()
    
    --nighttime shader
    if round.difficulty >= 20 then drawNightShader() end
    mainMap:drawLayer(mainMap.layers["Background"])
    love.graphics.setShader()
    
    drawGuns()
    if shaders.damaged then love.graphics.setShader(damagedShader) end
    if player.isInvincible then
      drawInvincibilityShader()
      love.graphics.setShader(invincibilityShader)
    end
    player.animation:draw(player.sprite, player.x, player.y, player_angle(), 1, 1, player.frame:getWidth()/2, 1 + player.frame:getHeight()/2)
    pausedAngle = player_angle()
    love.graphics.setShader()
    
    if round.difficulty >= 20 then drawNightShader() end
    
    --Particles
    love.graphics.draw(player.p.pSystem, player.x, player.y, nil, 1, 1)
    love.graphics.draw(player.dashP.pSystem, player.x, player.y, nil, 1, 1)
    
    -- Draw all objects
    drawEverything()
    gPopupManager:render()
    collisionDebug()
    
    --Energy
    drawEnergy(player.x - 6.7, player.y + 10, energy.width, energy.height, player.isRecharge)
    
    ret1,ret2 = cam:mousePosition()
    love.graphics.draw(reticle, ret1, ret2,nil,nil,nil,3,3)
    
    love.graphics.setShader()
--    if currentPrompt == nil then
--      currentPrompt = prompts.wasd
--    end
--    drawPrompt(currentPrompt, origin + 130, origin2 + 40, prompts.alpha.alpha)
    
    cam:detach()
    cam:zoomTo(6)
    
    --useful camera-translated coordinates
    origin,origin2 = cam:worldCoords(0,0)
    origin2Bot = origin2 + (screen_height / 6)
    originRight = origin + (screen_width / 6)
    originXCenter, originYCenter = cam:worldCoords(screen_width/2, screen_height/2)
    
    cam:attach()
    --Health
    love.graphics.draw(round.uiBox3, origin, origin2Bot - 12)
    player.healthBar.animation:draw(player.healthBar.sprite, origin - 1, origin2Bot - 14, nil, 5, 5)
    love.graphics.draw(player.heartIcon, origin + 4, origin2Bot - 12, nil, nil, nil, 4)
    
    --Reload
    love.graphics.printf(guns.equipped.currAmmo .. "/" .. guns.equipped.clipSize, origin - 24, origin2Bot - 34, 100, "right", nil, .8, .8)
    love.graphics.draw(round.uiBox2, origin + 2, origin2Bot - 22)
    drawReload(origin + 4, origin2Bot - 19, reloader.width, reloader.height)
    love.graphics.draw(player.ammoIcon, origin + 7, origin2Bot - 23, nil, nil, nil, 6)
    
    --Gold
    love.graphics.printf(math.floor(gold.total), origin + 20, origin2 + 4, 100, "left")
    love.graphics.draw(gold.bigSprite, origin + 2, origin2 + 2)
    
    --Round
    love.graphics.draw(round.uiBox, origin + 2, origin2 + 21)
    love.graphics.printf("Round", origin + 16, origin2 + 24, 100, "left", nil, .6, .6)
    love.graphics.draw(round.uiBox, origin + 2, origin2 + 37)
    love.graphics.printf(round.difficulty, origin + 28, origin2 + 40, 100, "left", nil, .6, .6)
    
    cam:detach()
    cam:zoomTo(currentZoom.zoom)
  elseif round.gameState == 3 then
    --shop
    cam:zoomTo(6)
    cam:attach()
    ret1,ret2 = cam:mousePosition()
    --useful camera-translated coordinates
    origin,origin2 = cam:worldCoords(0,0)
    origin2Bot = origin2 + (screen_height / zoom_factor)
    originRight = origin + (screen_width / zoom_factor)
    originXCenter, originYCenter = cam:worldCoords(screen_width/2, screen_height/2)
    
    love.graphics.setShader(shopShader)
    mainMap:drawLayer(mainMap.layers["Background"])
    love.graphics.setShader()
    
    --create buttons
    if not shopButtonsCreated then
      for i=1,#skills do
        local fn = skills[i]
        if i == 1 then
          newShopButton(originXCenter - 90, originYCenter - 70, fn)
        elseif i == 2 then
          newShopButton(originXCenter - 90, originYCenter - 35, fn)
        elseif i == 3 then
          newShopButton(originXCenter - 90, originYCenter, fn)
        elseif i == 4 then
          newShopButton(originXCenter - 90, originYCenter + 35, fn)
        elseif i == 5 then
          newShopButton(originXCenter + 20, originYCenter - 70, fn)
        elseif i == 6 then
          newShopButton(originXCenter + 20, originYCenter + 35, fn)
        end
      end
      
      shopButtonsCreated = true
    end
    
    displayShop()
    
    cam:detach()
    cam:zoomTo(currentZoom.zoom)
  elseif round.gameState == 5 then
    -- Pause screen
    cam:attach()
    --useful camera-translated coordinates
    origin,origin2 = cam:worldCoords(0,0)
    origin2Bot = origin2 + (screen_height / zoom_factor)
    originRight = origin + (screen_width / zoom_factor)
    originXCenter, originYCenter = cam:worldCoords(screen_width/2, screen_height/2)
    
    love.graphics.setShader(pauseShader)
    mainMap:drawLayer(mainMap.layers["Background"])
    drawEverything()
    player.animation:draw(player.sprite, player.x, player.y, pausedAngle, 1, 1, player.frame:getWidth()/2, 1 + player.frame:getHeight()/2)
    love.graphics.setShader()
    
    love.graphics.printf("PAUSED", originXCenter - 130, originYCenter - 10, 999, "left", nil, 4, 4)
    
    cam:detach()
  elseif round.gameState == 1 then
    gameOverScreen()
  end
end

function love.keypressed(key, unicode)
  for _,fn in ipairs(KEYPRESSED) do
    fn(key, unicode)
  end
end

function drawEverything()
  for i,z in ipairs(zombies) do
      love.graphics.draw(z.p.pSystem, z.x, z.y, nil, 3, 3)
      if z.damage == 10 then
        z.animation:draw(z.sprite, z.x, z.y, z.currentAngle+math.pi/2, 1, 1, z.frame:getWidth()/2, z.frame:getHeight()/2)
        if z.healthBar.isHidden == false then
          z.healthBar.animation:draw(z.healthBar.sprite, z.healthBar.x, z.healthBar.y, nil, .8, .8, 6, -5)
        end
      elseif z.damage == 25 then
        z.animation:draw(z.sprite, z.x, z.y, z.currentAngle+math.pi/2, 1, 1, z.frame:getWidth()/2, z.frame:getHeight()/2)
        if z.healthBar.isHidden == false then
          z.healthBar.animation:draw(z.healthBar.sprite, z.healthBar.x, z.healthBar.y, nil, 1.5, 1.5, 6, 8)
        end
      else
        z.animation:draw(z.sprite, z.x, z.y, z.currentAngle+math.pi/2, 1, 1, zomAssets.zombieWidth/2, 1 + zomAssets.zombieHeight/2)
        if z.healthBar.isHidden == false then
          z.healthBar.animation:draw(z.healthBar.sprite, z.healthBar.x, z.healthBar.y, nil, .8, .8, 7, 2)
        end
      end
    end
    
    for i,b in ipairs(bullets) do
      love.graphics.draw(b.sprite, b.x, b.y, b.direction, 1, 1, b.offsX, b.offsY)
    end
    
    drawCoins()
    drawPowerups()
    drawGrenades()
end

function collisionDebug()
  local items, length = world:getItems()
  love.graphics.setColor(1,0,0,1)
  for i, item in pairs(items) do
    local x,y,w,h = world:getRect(item)
    love.graphics.rectangle('line', x,y,w,h)
  end
  love.graphics.setColor(1,1,1,1)
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

function grenade_angle(g, z)
  local a,b = cam:cameraCoords(g.x, g.y)
  local c,d = cam:cameraCoords(z.x, z.y)
  return math.atan2(d - b, c - a) + math.pi/2
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

function linInterp(min,max,fraction)
  return ((max - min) * fraction + min)
end

function rgb(integer)
  return integer/255
end