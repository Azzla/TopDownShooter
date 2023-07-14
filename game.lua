local game = {}

--states
local shop = require('shop')

--modules
----map
sti = require('libs/SimpleTI/sti')
mainMap = sti('sprites/map/mainMapV2.lua')
map_width = mainMap.width * mainMap.tilewidth
map_height = mainMap.height * mainMap.tileheight

require('guns')
player = require('player')
require('zombie')
require('bullets')
require('grenades')
require('healthbar')
require('gold')
require('expManager')
require('gameCam')
require('energy')
require('powerups')

function player_angle()
  local a,b = cam:cameraCoords(cam:mousePosition())
  local c,d = cam:cameraCoords(player.x, player.y)
  return math.atan2(d - b, c - a) - math.pi/2
end

require('melees')

local function drawObjects()
  --sort by which sprites should appear on top of others
  drawZombies()
  drawBullets()
  drawCoins()
  drawXP()
  drawPowerups()
  drawGrenades()
end

function game:init()
  self.textManager = require('textManager')
  self.inventory = require('inventoryManager').init()
  self.main_canvas = love.graphics.newCanvas(map_width, map_height)
  self.main_canvas:renderTo(function()
    mainMap:drawTileLayer(mainMap.layers["Background"])
  end)
  
  self.difficulty = 1
  self.timeBetweenSpawns = 1.4
  self.roundTime = 5 -- seconds
  self.roundTimeReset = 30
  self.next = true
  self.canSpawn = true
  self.zombiesSpawned = 0
  self.zombiesMaxSpawn = 1
  self.totalKilled = 0
  self.currentKilled = 0
  self.uiBox = love.graphics.newImage('sprites/ui/UIBox1.png')
  self.uiBox2 = love.graphics.newImage('sprites/ui/UIBox2.png')
  self.uiBox3 = love.graphics.newImage('sprites/ui/UIBox3.png')
  self.heartIcon = love.graphics.newImage('sprites/heartIcon.png')
  self.ammoIcon = love.graphics.newImage('sprites/energyIcon.png')
  self.bulletCount = 0
  self.isDespawning = false
  self.despawnText = false
  self.despawnTime = 3.5
  self.despawnMagBonus = 50
  self.uiZoom = 6

  self.roundTimer = globalTimer.new()
  self.dropIndex = 0

  self.roundTimer:every(self.timeBetweenSpawns, function()
    if not self.isDespawning then
      self:doZombieSpawning(self.difficulty)
    end
  end)
end

function game:update(dt)
  self.runRoundTimer(self, dt)
  self.roundTimer:update(dt)
  self.textManager.update(dt, self)
  player:update(dt, shop.skills.speed, self)
  
  cameraHandler(dt, player.x, player.y, currentZoom.zoom)
  updateMelee(dt, player_angle())
  zombieUpdate(dt, self)
  bulletUpdate(dt)
  autoShoot(dt)
  grenadeUpdate(dt)
  updateGold(dt, shop.skills.magnet)
  updateXP(dt, shop.skills.magnet)
  energyUpdate(dt)
  powerupUpdate(dt, self, shop.skills.magnet)
  
  updateShaderTimers(dt)
  mainMap:update(dt)
  
  if not self.canSpawn and self.next then
    game:despawning()
  end
end

function game:draw()
  cam:zoomTo(currentZoom.zoom)
  cam:attach()
  
  --nighttime shader
--  if self.difficulty >= 40 then drawNightShader() end
  love.graphics.draw(self.main_canvas)
  
  --Objects
  drawObjects()
  --collisionDebug()
  if not melee.active then drawGuns() end
  
  --Player
  if shaders.damaged then love.graphics.setShader(damagedPlayerShader) end
  
  if player.isInvincible then
    drawInvincibilityShader()
    love.graphics.setShader(invincibilityShader)
  end
  
  if melee.active then
    drawMelee()
  else
    player:draw()
  end
  
  pausedAngle = player_angle()
  love.graphics.setShader()

  --In-Game Text
  self.textManager.drawGame()
  
  --Energy
  drawEnergy(player.x - 6.7, player.y + 10, player.stamina.width, player.stamina.height, player.isRecharge)
  
  local ret1,ret2 = cam:mousePosition()
  local fix = 0
  if guns.equipped == guns['railgun'] then fix = 60 end
  local offX,offY = offsetXY(guns.equipped.bulletOffsX,guns.equipped.bulletOffsY+fix,player_angle())
  
  love.graphics.draw(reticle, ret1, ret2,nil,nil,nil,3,3)
  love.graphics.setShader()
  
  self:drawUI()
end

function game:drawUI()
  cam:detach()
  cam:zoomTo(game.uiZoom)
  --useful camera-translated coordinates
  local origin,origin2,origin2Bot,originRight,originXCenter,originYCenter = cameraCoordinates(cam, 6)
  
  cam:attach()
  --Health
  love.graphics.draw(self.uiBox3, origin + 5, origin2Bot - 12)
  --player.healthBar.animation:draw(player.healthBar.sprite, origin + 4, origin2Bot - 14, nil, 5, 5)
  love.graphics.draw(self.heartIcon, origin + 8, origin2Bot - 12, nil, nil, nil, 4)
  
  --Reload
  love.graphics.printf(guns.equipped.currAmmo .. "/" .. guns.equipped.clipSize, origin - 19, origin2Bot - 34, 100, "right", nil, .8, .8)
  love.graphics.draw(game.uiBox2, origin + 7, origin2Bot - 22)
  drawReload(origin + 9, origin2Bot - 19, reloader.width, reloader.height)
  love.graphics.draw(self.ammoIcon, origin + 12, origin2Bot - 23, nil, nil, nil, 6)
  
  --Gold
  love.graphics.printf(math.floor(gold.total), origin + 20, origin2 + 4, 100, "left")
  love.graphics.draw(gold.bigSprite, origin + 2, origin2 + 2)
  
  --Timer
  love.graphics.printf(math.ceil(self.roundTime), originRight - 25, origin2 + 5, 50)
  
  --Inventory
  game.inventory:draw(originXCenter, origin2)
  
  --UI Text
  self.textManager.drawUI(origin,origin2,origin2Bot,originRight,originXCenter,originYCenter)
  
  --Round
  love.graphics.draw(self.uiBox, origin + 2, origin2 + 21)
  love.graphics.printf("Round", origin + 10, origin2 + 24.5, 100, "left", nil, .5, .5)
  love.graphics.printf(self.difficulty, origin + 44, origin2 + 24.5, 100, "left", nil, .5, .5)
  
  --XP
  local xpOffsetsX,xpOffsetsY = -17,33
  love.graphics.printf("lvl " .. exp.currentLevel, origin + 38 + xpOffsetsX, origin2 + 11 + xpOffsetsY, 100, "right", nil, .35, .35)
  love.graphics.draw(game.uiBox2, origin + 20 + xpOffsetsX, origin2 + 2 + xpOffsetsY)
  drawXPBar(origin + 22 + xpOffsetsX, origin2 + 5 + xpOffsetsY,expBarTweenCurr.w,expBarTweenCurr.h)
  
  cam:detach()
end

function game:runRoundTimer(dt)
  if self.roundTime > 0 and not self.isDespawning then
    self.roundTime = math.max(self.roundTime - dt, 0)
  else
    self.canSpawn = false
  end
end

function game:despawning()
  self.next = false
  self.zombiesSpawned = 0
  self.currentKilled = 0
  self.bulletCount = 0
  
  self:removeObjects({coins = true, xp = true})
  shop.skills.magnet = shop.skills.magnet * self.despawnMagBonus
  self.isDespawning = true
  self.despawnText = false
  
  self.dropIndex = self.textManager.dropsDespawning(self.despawnTime)
  
  self.roundTimer:after(self.despawnTime, function()
    self.isDespawning = false
    self.canSpawn = true
    self.next = true
    self.roundTime = self.roundTimeReset
    shop.skills.magnet = shop.skills.magnet / self.despawnMagBonus
    self.difficulty = self.difficulty + 1
    
    Gamestate.switch(shop)
  end)
end

function game:keypressed(key)
  if key == "end" then
    love.event.quit()
  elseif key == "escape" then
    player:destroy()
    Gamestate.switch(self.picker)
  elseif key == "right" then
    game:despawning()
  elseif key == 'f' then
    if shop.skills.grenades >= 1 then
      love.audio.play(soundFX.dash)
      spawnGrenade(self)
      shop.skills.grenades = shop.skills.grenades - 1
    end
  else
    gunKeybinds(key)
    player:keybinds(key, shop.skills.speed)
    self.inventory:keybinds(key)
  end
end

function game:mousereleased(x, y, btn)
  if not shop.cooldown then
    if btn == 1 then
      --stop warming guns with warming time, like chaingun
      if guns.equipped.hasWarmup then
        guns.equipped.warm = false
        guns.equipped.isWarming = false
        coolingDown = false
        warmingTimer:clear()
        love.audio.stop(guns.equipped.warmSound)
        love.audio.stop(soundFX.firingWarm)
      elseif guns.equipped.currAmmo > 0 and canShoot and not coolingDown then
        fireBullets()
        
        if guns.equipped.currAmmo == 0 then reload() end
      elseif guns.equipped.currAmmo == 0 then
        reload()
      end
      --grenades
    elseif btn == 2 and not melee.active then
      meleeAttack()
    end
  end
end

function game:enter(previous, character)
  if not self.picker then self.picker = previous end
  if previous == self.picker then
    self:removeObjects()
    player:init(character)
  end
end

function game:removeObjects(removeParams) -- { zombies = true, powerups = true }
  --remove anything that isn't excluded by parameters
  local _table = removeParams or {}
  
  if not _table.zombies then
    for i=#zombies,1,-1 do
      local z = zombies[i]
      z.dead = true
    end
  end
  if not _table.coins then
    for i=#coins,1,-1 do
      local c = coins[i]
      c.collected = true
    end
  end
  if not _table.xp then
    for i=#exp_instances,1,-1 do
      local x = exp_instances[i]
      x.collected = true
    end
  end
  if not _table.bullets then
    for i=#bullets,1,-1 do
      local b = bullets[i]
      b.dead = true
    end
  end
  if not _table.powerups then
    for i=#powerupsActive,1,-1 do
      local p = powerupsActive[i]
      p.dead = true
    end
  end
end
  
function game:doZombieSpawning(currentRound)
  spawnZombie('normal')
  self.zombiesSpawned = self.zombiesSpawned + 1
  if currentRound >= 5 and self.zombiesSpawned % 7 == 0 then spawnZombie('big') end
  if currentRound >= 10 then spawnZombie('small') end
  if currentRound >= 15 then spawnZombie('shooter') end
end

return game