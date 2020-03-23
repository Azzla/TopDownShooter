function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setMode(1920, 1080)
  
  anim8 = require('anim8-master/anim8')
  require('player')
  require('zombie')
  require('bullets')
  require('healthbar')
  require('rounds')
  require('shop')
  require('gold')
  sti = require('SimpleTI/sti')
  cameraFile = require('hump-master/camera')
  cam = cameraFile()
  cam:zoom(4)
  cam:lookAt(player.x, player.y)
  
  reticle = love.graphics.newImage('sprites/cursor.png')
  love.mouse.setVisible(false)
  
  mainMap = sti('sprites/mainMap.lua')
  spawnHealthBar(true)
  
  boundaries = {}
  for i,obj in pairs(mainMap.layers["Bounds"].objects) do
    spawnBoundaries(obj.x, obj.y, obj.width, obj.height)
  end
end

function love.update(dt)
  cam:lockPosition(player.x, player.y, cam.smooth.damped(8))
  
  playerUpdate(dt)
  walkAnimation(dt)
  zombieUpdate(dt)
  bulletUpdate(dt)
  healthBarUpdate(dt, player)
  updateRounds(dt)
  autoShoot(dt)
  
  mainMap:update(dt)
end

function love.draw()
  if round.gameState == 2 then
    cam:attach()
    
    mainMap:drawLayer(mainMap.layers["Background"])
    
    player.animation:draw(player.sprite, player.x, player.y, player_angle(), 1, 1, player.frame:getWidth()/2, 1 + player.frame:getHeight()/2)
    
    for i,z in ipairs(zombies) do
      z.animation:draw(z.sprite, z.x, z.y, zombie_angle(z), 1.2, 1.2, z.frame:getWidth()/2, z.frame:getHeight()/2)
    end
    
    for i,b in ipairs(bullets) do
      love.graphics.draw(b.sprite, b.x, b.y, b.direction, 1.2, 1.2, 3, 3)
    end
    
    for i,h in ipairs(healthbars) do
      h.animation:draw(h.sprite, h.x, h.y, nil, 1.5, 1.5, 6)
      if h.isPlayer == true then
        love.graphics.print(h.health, h.x - 8, h.y - 5, nil, .5, .5)
      end
    end
    
    origin,origin2 = cam:worldCoords(love.graphics.getWidth()/2,0)
    love.graphics.printf("Gold: "..math.floor(gold.total), origin, origin2, 100, "center", nil, nil, nil, 50)
    love.graphics.printf("Round: "..round.difficulty, origin, origin2 + 20, 100, "center", nil, nil, nil, 50)
    love.graphics.printf("Total Kills: "..round.totalKilled, origin, origin2 + 40, 100, "center", nil, nil, nil, 50)
    
    ret1,ret2 = cam:mousePosition()
    love.graphics.draw(reticle, ret1, ret2,nil,nil,nil,3,3)
    
    cam:detach()
  elseif round.gameState == 3 then
    displayShop()
    love.graphics.draw(reticle, love.mouse:getX(), love.mouse:getY(),nil,4,4,3,3)
  end
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

function spawnBoundaries(x, y, width, height)
  local bounds = {}
end