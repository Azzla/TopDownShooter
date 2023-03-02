local MeleeParticleManager = require('particleManager')

melee = {}
melee.equipped = nil
melee.active = false
melee.timer = globalTimer.new()
starterSprite = love.graphics.newImage('sprites/melee.png')

local meleeSystem = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 500)
meleeSystem:setParticleLifetime ( .05,.4 )
meleeSystem:setSizes(1, .5, .25)
meleeSystem:setSizeVariation ( .5 )
meleeSystem:setSpeed(30, 50)

table.insert(KEYPRESSED, function(key, scancode)
  if key == 'f' and not melee.active then
    meleeAttack()
  end
end)

meleeOptions = {}
meleeOptions.starter = {
  sprite = starterSprite,
  height = starterSprite:getHeight(),
  width = starterSprite:getWidth(),
  id = -1,
  v = 100,
  offsX = 2,
  offsY = 26,
  dmg = 20,
  swipeTime = .08,
  angle = { -math.pi/3 },
  targetAngle = { math.pi/3 }
}

function meleeAttack()
  melee.equipped = meleeOptions.starter
  melee.equipped.x = player.x
  melee.equipped.y = player.y
  melee.equipped.direction = player_angle() + melee.equipped.angle[1]
  
  meleeTween = tween.new(melee.equipped.swipeTime, melee.equipped.angle, melee.equipped.targetAngle)
  melee.active = true
  love.audio.play(soundFX.slash)
  world:add(melee.equipped, melee.equipped.x - 15, melee.equipped.y - 15, melee.equipped.width, melee.equipped.height/2)
  
  melee.timer:after(melee.equipped.swipeTime, function()
    melee.active = false
    world:remove(melee.equipped)
    meleeTween:reset()
  end)

  MeleeParticleManager.spawn(meleeSystem, math.random(50,120), player_angle() -math.pi/3 -math.pi/2, math.pi/2, 1)
end

function drawMelee()
  if melee.active then
    love.graphics.draw(melee.equipped.sprite, melee.equipped.x, melee.equipped.y, melee.equipped.direction, 1, 1, melee.equipped.offsX, melee.equipped.offsY)
  end
  MeleeParticleManager.draw(meleeSystem, player.x, player.y, 2) --draws specified particle system at x,y
end

local meleeFilter = function(item, other)
  if other.isBullet then return nil
  elseif other.isGrenade then return nil
  elseif other.isPlayer then return nil
  elseif other.isZombie then return 'cross' end
end

function updateMelee(dt)
  melee.timer:update(dt)
  MeleeParticleManager.update(meleeSystem, dt)
  
  if melee.active then
    meleeTween:update(dt)
    
    melee.equipped.direction = player_angle() + melee.equipped.angle[1]
    melee.equipped.vx = math.cos(melee.equipped.direction - math.pi/2) * melee.equipped.v
    melee.equipped.vy = math.sin(melee.equipped.direction - math.pi/2) * melee.equipped.v
    
    local goalX = melee.equipped.x + melee.equipped.vx * dt
    local goalY = melee.equipped.y + melee.equipped.vy * dt
    local actualX, actualY, cols, length = world:move(melee.equipped, goalX, goalY, meleeFilter)
    melee.equipped.x, melee.equipped.y = actualX, actualY
    
    for i=1,length do
      local other = cols[i].other
      if other.isZombie and melee.equipped.id ~= other.id then
        melee.equipped.id = other.id
        
        TextManager.grenadeDmgPopup(melee.equipped, other)
        other.zombieDamaged = true
        shaderTimer:after(.08, function()
          other.zombieDamaged = false
          melee.equipped.id = -1
        end)
        
        other.healthBar.isHidden = false
        other.health = other.health - melee.equipped.dmg
        love.audio.stop(soundFX.zombies.hit)
        love.audio.play(soundFX.zombies.hit)
        
        if other.health <= 0 then
          other.dead = true
          round.totalKilled = round.totalKilled + 1
          round.currentKilled = round.currentKilled + 1
          spawnKillReward(other)
          powerupChance(other)
          
          spawnBlood(other.x,other.y)
        end
      end
    end
  end
end