function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  love.window.setMode(0, 0)
--  love.window.setMode(1920, 1080)
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
--  love.window.setFullscreen(true, "desktop")
  
  --font
  pixelFont = love.graphics.newFont('fonts/Minecraft.ttf', 16)
  love.graphics.setFont(pixelFont)
  pixelFont:setFilter( "nearest", "nearest" )
  
  --map
  sti = require('libs/SimpleTI/sti')
  mainMap = sti('sprites/map/mainMapV2.lua')
  map_width = mainMap.width * mainMap.tilewidth
  map_height = mainMap.height * mainMap.tileheight
  
  gameOverGraphic = love.graphics.newImage('sprites/ui/gameOver.png')
  
  --libs
  require('libs/slam')
  globalTimer = require('libs/hump/timer')
  tween = require('libs/tween/tween')
  anim8 = require('libs/anim8/anim8')
  bump = require('libs/bump/bump')
  world = bump.newWorld(32)
  
  --modules
  KEYPRESSED={}
  TextManager = require('textManager')
  require('shaders')
  require('sounds')
  loadSoundFX()
  require('menu')
  require('prompts')
  require('guns')
  require('player')
  require('zombie')
  require('bullets')
  require('grenades')
  require('melees')
  require('healthbar')
  require('rounds')
  require('shop')
  require('gold')
  require('gameCam')
  require('energy')
  require('powerups')
  
  spawnPlayerHealthBar()
  nightCycle()
  reticle = love.graphics.newImage('sprites/cursor.png')
  love.mouse.setVisible(false)
  pausedAngle = nil
end

function love.update(dt)
  gameMusic(dt)
  if round.gameState == 4 then
    globalTimer.update(dt)
  end
  if round.gameState == 2 then
    TextManager.update(dt)
    updatePromptAlpha(dt)
    updateShaderTimers(dt)
    updateCameraTimers(dt)
    cameraHandler(player.x, player.y, dt)
    playerUpdate(dt)
    walkAnimation(dt)
    zombieUpdate(dt)
    bulletUpdate(dt)
    updateMelee(dt)
    autoShoot(dt)
    grenadeUpdate(dt)
    updateRounds(dt)
    updateGold(dt)
    energyUpdate(dt)
    powerupUpdate(dt)
    roundTimer:update(dt)
    mainMap:update(dt)
    if player.canDash == false then
      dashTimer:update(dt)
    end
  end
  if round.gameState == 3 then
    shopUpdate(dt)
  end
end

function love.draw()
  if round.gameState == 4 then
    --------MENU--------
    local ret1,ret2 = love.mouse:getPosition()
    mainMenu(ret1,ret2)
    
  elseif round.gameState == 6 then
    --------HELP--------
    local ret1,ret2 = love.mouse:getPosition()
    helpScreen(ret1,ret2)
    
  elseif round.gameState == 2 then
    --------GAMEPLAY--------
    cam:zoomTo(currentZoom.zoom)
    cam:attach()
    
    --nighttime shader
    if round.difficulty >= 40 then drawNightShader() end
    
    mainMap:drawLayer(mainMap.layers["Background"])
    
    --Objects
    drawObjects()
    drawGuns()
    drawMelee()
    
    --Player
    if shaders.damaged then love.graphics.setShader(damagedPlayerShader) end
    
    if player.isInvincible then
      drawInvincibilityShader()
      love.graphics.setShader(invincibilityShader)
    end
    
    drawPlayer()
    pausedAngle = player_angle()
    
    love.graphics.setShader()
    
    --Nighttime
    --if round.difficulty >= 40 then drawNightShader() end
    
    --In-Game Text
    TextManager.drawGame()
    
--    collisionDebug()

    --Energy
    drawEnergy(player.x - 6.7, player.y + 10, energy.width, energy.height, player.isRecharge)
    
    local ret1,ret2 = cam:mousePosition()
    --magical magics
    local handDistance = math.sqrt(guns.equipped.bulletOffsX^2 + guns.equipped.bulletOffsY^2)
    local handAngle    = player_angle() + math.atan2(guns.equipped.bulletOffsY, guns.equipped.bulletOffsX)
    local handOffsetX  = handDistance * math.cos(handAngle)
    local handOffsetY  = handDistance * math.sin(handAngle)
    --magical magics
    love.graphics.draw(reticle, ret1+handOffsetX, ret2+handOffsetY,nil,nil,nil,3,3)
    
    love.graphics.setShader()
    
    cam:detach()
    cam:zoomTo(6)
    --useful camera-translated coordinates
    local origin,origin2,origin2Bot,originRight,originXCenter,originYCenter = cameraCoordinates(cam, 6)
    
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
    
    --UI Text
    TextManager.drawUI(origin,origin2,origin2Bot,originRight,originXCenter,originYCenter)
    
    --Round
    love.graphics.draw(round.uiBox, origin + 2, origin2 + 21)
    love.graphics.printf("Round", origin + 16, origin2 + 24, 100, "left", nil, .6, .6)
    love.graphics.draw(round.uiBox, origin + 2, origin2 + 37)
    love.graphics.printf(round.difficulty, origin + 28, origin2 + 40, 100, "left", nil, .6, .6)
    
    cam:detach()
    cam:zoomTo(currentZoom.zoom)
  elseif round.gameState == 3 then
    --------SHOP--------
    cam:zoomTo(6)
    cam:attach()
    local ret1,ret2 = cam:mousePosition()
    --useful camera-translated coordinates
    local origin,origin2,origin2Bot,originRight,originXCenter,originYCenter = cameraCoordinates(cam, 6)
    
    love.graphics.setShader(shopShader)
    mainMap:drawLayer(mainMap.layers["Background"])
    love.graphics.setShader()
    
--    displayShop(origin,origin2,origin2Bot,originRight,originXCenter,originYCenter,ret1,ret2)
    displayUpgrades(origin,origin2,origin2Bot,originRight,originXCenter,originYCenter,ret1,ret2)
    
    cam:detach()
    cam:zoomTo(currentZoom.zoom)
  elseif round.gameState == 5 then
    --------PAUSE--------
    cam:attach()
    --useful camera-translated coordinates
    local origin,origin2,origin2Bot,originRight,originXCenter,originYCenter = cameraCoordinates(cam, 6)
    
    love.graphics.setShader(pauseShader)
    mainMap:drawLayer(mainMap.layers["Background"])
    drawObjects()
    player.animation:draw(player.sprite, player.x, player.y, pausedAngle, 1, 1, player.frame:getWidth()/2, 1 + player.frame:getHeight()/2)
    love.graphics.setShader()
    
    love.graphics.printf("PAUSED", originXCenter - 130, originYCenter - 10, 999, "left", nil, 4, 4)
    
    local ret1,ret2 = cam:mousePosition()
    love.graphics.draw(reticle, ret1, ret2,nil,nil,nil,3,3)
    
    cam:detach()
    cam:zoomTo(currentZoom.zoom)
  elseif round.gameState == 1 then
    --------GAMEOVER--------
    gameOverScreen()
  end
end

function gameOverScreen()
  love.graphics.draw(gameOverGraphic, 0, 0, nil, love.graphics.getWidth() / gameOverGraphic:getWidth(), love.graphics.getHeight() / gameOverGraphic:getHeight())
end

function love.keypressed(key, unicode)
  for _,fn in ipairs(KEYPRESSED) do
    fn(key, unicode)
  end
end

function cameraCoordinates(c, scale)
  local o,o2 = c:worldCoords(0,0)
  local oB = o2 + (screen_height / scale)
  local oR = o + (screen_width / scale)
  local oXC, oYC = c:worldCoords(screen_width/2, screen_height/2)
  
  return o,o2,oB,oR,oXC,oYC
end

function drawObjects()
  drawZombies()
  drawBullets()
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

-------------------------
--------UTILITIES--------
-------------------------
function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
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