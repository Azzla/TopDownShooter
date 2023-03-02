powerupsActive = {}
powerups = {}
--sprites
powerups.sprites = {
  love.graphics.newImage('sprites/healthUp.png'),
  love.graphics.newImage('sprites/damageUp.png'),
  love.graphics.newImage('sprites/speedUp.png'),
  love.graphics.newImage('sprites/invincibility.png')
}
--effects
powerups.effects = {10, 1.5, 290} --health, damage multi, bonus speed
healthUpHealth = 10
damageUpMult = 1.5
speedUpMult = 1.5

powerupTimer = globalTimer.new()

powerupAlpha = { alpha = 1 }
targetPowerupAlpha = { alpha = 0 }
powerupTween = tween.new(.5, powerupAlpha, targetPowerupAlpha)
local flag = true

function spawnPowerup(index, zombie)
  local powerup = {}
  powerup.x = zombie.x
  powerup.y = zombie.y
  powerup.id = index
  powerup.sprite = powerups.sprites[index]
  powerup.isVisible = true
  powerup.value = powerups.effects[index]
  powerup.dead = false
  powerup.timer = powerupTimer:new()
  powerup.active = false
  powerup.hitRadius = 12
  powerup.collision = true
  powerup.duration = 1
  powerup.speed = math.random(70+math.ceil(shop.skills.magnet*4),120+math.ceil(shop.skills.magnet*4))
  
  if powerup.id == 2 then
    powerup.duration = 10
    powerup.type = 'DAMAGE x2'
  elseif powerup.id == 3 then
    powerup.duration = 10
    powerup.type = 'SPEED UP'
  elseif powerup.id == 4 then
    powerup.duration = 10
    powerup.type = 'INVINCIBILITY'
  else
    powerup.type = 'HEALTH +'..tostring(healthUpHealth)
  end
  
  table.insert(powerupsActive, powerup)
end

--3% chance on kill to get a powerup drop.  From there, we determine which powerup to give according to the chances table weights.
function powerupChance(zombie)
  local random = math.random(1, 100)
  
  if random > 97 then
    --chances
    local chances = {100,200,300,400} --health / damage / speed / invincibility
    local total = chances[#chances] --value of last item in table
    local noPowerupChosen = true
    
    while (noPowerupChosen) do
      local randWeight = math.random(1, total)
      
      for i,p in ipairs(chances) do
        if randWeight <= p then
          spawnPowerup(i, zombie)
          noPowerupChosen = false
          break
        end
      end
    end
  end
end

function activatePowerup(powerup)
  powerup.timer:after(powerup.duration, function() powerup.dead = true end)
  powerup.isVisible = false
  powerup.active = true
  
  if powerup.id == 1 then
    -- health up
    if (player.health < 100) then
      player.health = player.health + healthUpHealth
      if player.health > 100 then player.health = 100 end
    end
    love.audio.play(soundFX.health)
  elseif powerup.id == 2 then
    -- damage x1.5
    player.damageUp = true
    love.audio.play(soundFX.powerup)
  elseif powerup.id == 3 then
    --speed up
    player.bonusV = powerup.value
    love.audio.play(soundFX.powerup)
  elseif powerup.id == 4 then
    -- invincibility
    player.isInvincible = true
    love.audio.play(soundFX.invincible)
  end
end

function drawPowerups()
  for i,p in ipairs(powerupsActive) do
    if p.isVisible == true then
      love.graphics.setColor(1,1,1,powerupAlpha.alpha)
      love.graphics.draw(p.sprite, p.x, p.y, nil, nil, nil, 8, 8)
      love.graphics.setColor(1,1,1,1)
    end
  end
end

function powerupUpdate(dt)
  if round.gameState == 2 then
    for i,pow in ipairs(powerupsActive) do
      pow.timer:update(dt)
      
      if distanceBetween(pow.x, pow.y, player.x, player.y) > pow.hitRadius and distanceBetween(pow.x, pow.y, player.x, player.y) < (25 * shop.skills.magnet) then
        pow.x = pow.x + math.cos(zombie_angle_wrld(pow)) * pow.speed * dt
        pow.y = pow.y + math.sin(zombie_angle_wrld(pow)) * pow.speed * dt
      elseif distanceBetween(player.x, player.y, pow.x, pow.y) <= pow.hitRadius and pow.collision then
        for i,p in pairs(powerupsActive) do
          if p.active and p.id == pow.id then
            p.active = false
            p.timer:clear()
          end
        end
        pow.collision = false
        activatePowerup(pow)
        TextManager.genericPopup(player.x, player.y, pow.type)
      end
    end
    
    for i=#powerupsActive,1,-1 do
      local p = powerupsActive[i]
      
      if p.dead then
        if p.id == 2 then
          player.damageUp = false
        elseif p.id == 3 then
          player.bonusV = 0
        elseif p.id == 4 then
          player.isInvincible = false
        end
        
        table.remove(powerupsActive, i)
      end
    end
    
    if round.isDespawning then
      if powerupAlpha.alpha <= 1 and flag then
        powerupTween:update(dt)
        if powerupAlpha.alpha == 0 then flag = false end
      end
      if powerupAlpha.alpha >= 0 and not flag then
        powerupTween:update(-dt)
        if powerupAlpha.alpha == 1 then flag = true end
      end
      
    elseif not round.isDespawning and powerupAlpha.alpha ~= 1 then powerupAlpha.alpha = 1 end
  end
end