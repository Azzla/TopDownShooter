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
powerups.effects = {10, 1.5, 2}
healthUpHealth = 10
damageUpMult = 1.5
speedUpMult = 1.5

powerupTimer = globalTimer.new()

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
  
  if powerup.id == 2 then
    powerup.duration = 10
  elseif powerup.id == 3 then
    powerup.duration = 10
  elseif powerup.id == 4 then
    powerup.duration = 10
  end
  
  table.insert(powerupsActive, powerup)
end

--5% chance on kill to get a powerup drop.  From there, we determine which powerup to give according to the chances table weights.
function powerupChance(zombie)
  local random = math.random(1, 100)
  
  if random > 94 then
    --chances
    local chances = {100,110,120,126} --health / damage / speed / invincibility
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
    if (player.health < 100) then
      player.health = player.health + healthUpHealth
      if player.health > 100 then player.health = 100 end
    end
    love.audio.play(soundFX.health)
  elseif powerup.id == 2 then
    player.damageUp = true
    love.audio.play(soundFX.powerup)
  elseif powerup.id == 3 then
    player.v = player.v * powerup.value
    love.audio.play(soundFX.powerup)
  elseif powerup.id == 4 then
    player.isInvincible = true
    love.audio.play(soundFX.invincible)
  end
end

function powerupUpdate(dt)
  if round.gameState == 2 then
    for i,pow in ipairs(powerupsActive) do
      pow.timer:update(dt)
      
      if distanceBetween(player.x, player.y, pow.x, pow.y) <= pow.hitRadius and pow.collision then
        for i,p in pairs(powerupsActive) do
          if p.active and p.id == pow.id then
            p.active = false
            p.timer:clear()
          end
        end
        pow.collision = false
        activatePowerup(pow)
      end
    end
    
    for i=#powerupsActive,1,-1 do
      local p = powerupsActive[i]
      
      if p.dead == true then
        if p.id == 2 then
          player.damageUp = false
        elseif p.id == 3 then
          player.v = player.v / p.value
        elseif p.id == 4 then
          player.isInvincible = false
        end
        
        table.remove(powerupsActive, i)
      end
    end
    
  end
end