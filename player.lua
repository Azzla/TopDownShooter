local player = {}

function player:init(character)
  self.particleManager = require('particleManager')
  self.dashSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
  self.dashSystem:setParticleLifetime (.05, .3)
  self.dashSystem:setSizes(1)
  self.dashSystem:setSpeed(60)
  self.dashP = self.particleManager.new(self.x, self.y, self.dashSystem, 1)
  self.stamina = { width = 0, height = 1}
  self.staminaTarget = { width = 15, height = 1}
  self.grid = anim8.newGrid(16, 16, 128, 16)
  self.animation = anim8.newAnimation(self.grid("1-8",1), 0.08)
  self.timer = globalTimer.new()
  
  self.x = map_width / 2
  self.y = map_height / 2
  self.vx = 0
  self.vy = 0
  self.sprite = character.sprite
  self.spriteWalk = character.spriteWalk
  self.w = self.sprite:getWidth()
  self.h = self.sprite:getHeight()
  self.hp = character.hp
  self.maxHp = character.hp
  self.armor = character.armor
  self.dmg = character.dmg
  self.v = character.v
  self.bonusV = character.bonusV
  self.friction = character.friction
  self.canDash = character.canDash
  if self.canDash then
    self.dashCooldown = character.dashCooldown
    self.isRecharge = character.isRecharge
    self.dashTween = tween.new(self.dashCooldown, self.stamina, self.staminaTarget)
  end
  
  self.coll = HC.rectangle(map_width / 2, map_height / 2, self.w * .75, self.h * .75)
  
  self.isPlayer = true
  self.isInvincible = false
  self.damageUp = false
end

function player:keybinds(key, upgradeSpeed, player)
  if key == 'space' and self.canDash then
    love.audio.play(soundFX.dash)
    self.particleManager.spawn(self.dashP.psys, math.random(12,24), 0, math.pi*2, 1)
    self.canDash = false
    self.isRecharge = false
    
    self.timer:after(self.dashCooldown, function()
      self.canDash = true
      self.isRecharge = true
    end)
    
    if love.keyboard.isDown("a") then
      self.vx = self.vx - (self.v+upgradeSpeed)/2
    end
    if love.keyboard.isDown("d") then
      self.vx = self.vx + (self.v+upgradeSpeed)/2
    end
    if love.keyboard.isDown("w") then
      self.vy = self.vy - (self.v+upgradeSpeed)/2
    end
    if love.keyboard.isDown("s") then
      self.vy = self.vy + (self.v+upgradeSpeed)/2
    end
    self.dashTween:reset()
  end
end

function player:draw()
  self.animation:draw(self.spriteWalk, self.x, self.y, player_angle(), 1, 1, self.w/2, 1 + self.h/2)
  self.particleManager.draw(self.dashP.psys, self.x, self.y)
end

function player:update(dt, speedUpgrade, game)
  self.particleManager.update(self.dashP.psys, dt)
  self.timer:update(dt)
  
  --walk animation
  if love.keyboard.isDown('w','a','s','d') then
    self.animation:update(dt)
    soundFX.move:resume()
  else
    self.animation:gotoFrame(1)
    soundFX.move:pause()
  end
  
  --death
  if self.hp <= 0 then
    self.hp = self.maxHp
    Gamestate.switch(game.menu)
  end
  
  --movement
  local penalty = 0
  if love.mouse.isDown(1) and guns.equipped.tween and canShoot then
    penalty = guns.equipped.movementPenalty
    guns.equipped.tween:update(dt)
    guns.equipped.animation:update(dt/guns.equipped.frameTime.v)
  elseif guns.equipped.tween then
    guns.equipped.tween:reset()
  end
  
  if love.keyboard.isDown("a") then
    self.vx = self.vx - (self.v+speedUpgrade+self.bonusV-penalty)*dt
  end
  if love.keyboard.isDown("d") then
    self.vx = self.vx + (self.v+speedUpgrade+self.bonusV-penalty)*dt
  end
  if love.keyboard.isDown("w") then
    self.vy = self.vy - (self.v+speedUpgrade+self.bonusV-penalty)*dt
  end
  if love.keyboard.isDown("s") then
    self.vy = self.vy + (self.v+speedUpgrade+self.bonusV-penalty)*dt
  end
  
  if self.x <= 10 then
    self.vx = self.vx * -1
    self.x = self.x + 1
  end
  if self.y <= 10 then
    self.vy = self.vy * -1
    self.y = self.y + 1
  end
  if self.x >= map_width - 10 then
    self.vx = self.vx * -1
    self.x = self.x - 1
  end
  if self.y >= map_height - 10 then
    self.vy = self.vy * -1
    self.y = self.y - 1
  end
  
  self.vx = self.vx * (1 - math.min(dt*self.friction, .5))
  self.vy = self.vy * (1 - math.min(dt*self.friction, .5))
  
  --Collisions--
  local collisions = HC.collisions(self.coll)
  for other, separating_vector in pairs(collisions) do
    if other.parent.isMelee then return end
    
    local collides, dx, dy = self.coll:collidesWith(other)
    if collides and other.parent.collideable and not other.parent.dead then
      self:collide(other.parent, game)
    end
  end

  local goalX = self.x + self.vx * dt
  local goalY = self.y + self.vy * dt
  self.x = goalX
  self.y = goalY
  
  self.coll:moveTo(goalX,goalY)
  self.coll:setRotation(player_angle())
end

function player:collide(object, game)
  object.dead = true
  object.collideable = false
  if not self.invincible then
    self.hp = self.hp - (object.damage - self.armor)
    game.textManager.playerDmgPopup(self.x, self.y, object)

    
    screenShake(.15, 1)
    shaders.damaged = true
    shaderTimer:after(.1, function() shaders.damaged = false end)
    love.audio.play(soundFX.player_hit)
    
  elseif object.isZombie then
    spawnGoldReward(object)
    spawnXPReward(object)
    game.currentKilled = game.currentKilled + 1
  end
end

function player:addHealth()
  self.hp = self.hp + 25
  if self.hp > self.maxHp then self.hp = self.maxHp end
end

function player:destroy()
  HC.remove(self.coll)
end

return player