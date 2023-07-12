melee = {}
melee.equipped = nil
melee.active = false
melee.timer = globalTimer.new()

melee.weapons = {}
melee.weapons.katana = {}
melee.weapons.katana.sprite = love.graphics.newImage('sprites/melees/katana.png')
melee.weapons.katana.sheet = love.graphics.newImage('sprites/melees/chromeMelee.png')
melee.weapons.katana.grid = anim8.newGrid(60, 60, 540, 60)
melee.weapons.katana.animation = anim8.newAnimation(
  melee.weapons.katana.grid("1-9",1, "9-1",1),
  {['1-3']=0.08, ['4-9']=0.03, ['10-14']=0.08, ['15-18']=0.1}
)
melee.weapons.katana.height = melee.weapons.katana.sprite:getHeight()
melee.weapons.katana.width = 3
melee.weapons.katana.id = -1
melee.weapons.katana.v = 100
melee.weapons.katana.offsX = 33
melee.weapons.katana.offsY = 31
melee.weapons.katana.dmg = 30
melee.weapons.katana.speed = 800
melee.weapons.katana.knockback = -10
melee.weapons.katana.slowdown = .5
melee.weapons.katana.swipeTime = 1.04


function meleeAttack()
  canShoot = false
  melee.equipped = melee.weapons.katana
  melee.equipped.animation:gotoFrame(1)
  melee.equipped.direction = player_angle()
  melee.startA = { math.pi/3 }
  melee.finalA = { math.pi*1.3 }
  melee.tween = tween.new(.7, melee.startA, melee.finalA, "inOutBack")
--  
  melee.active = true
  melee.coll = HC.rectangle(player.x, player.y, melee.weapons.katana.sprite:getWidth(), melee.weapons.katana.sprite:getHeight())
  melee.coll:rotate(player_angle() + math.pi/2, player.x, player.y)
  melee.coll.parent = melee
  melee.colliding = true
  love.audio.play(soundFX.swordslash)
  
  melee.timer:after(melee.equipped.swipeTime, function()
    melee.active = false
    canShoot = true
  end)
  
  melee.timer:after(.5, function()
    melee.colliding = false
    HC.remove(melee.coll)
    melee.tween:reset()
  end)
end

function drawMelee()
  if melee.active then
    melee.equipped.animation:draw(melee.equipped.sheet, melee.equipped.x, melee.equipped.y, melee.equipped.direction, 1, 1, melee.equipped.offsX, melee.equipped.offsY)
  end
end

function updateMelee(dt, pAngle)
  melee.timer:update(dt)
  
  if melee.active then
    if melee.colliding then
      melee.tween:update(dt)
      local newAngle = pAngle + melee.startA[1]
      
      melee.coll:setRotation(newAngle, player.x, player.y - 2)
      
      local cX,cY = melee.coll:center()
      melee.coll:moveTo(cX + player.vx * dt, cY + player.vy * dt)
    end
    
    melee.equipped.animation:update(dt)
    melee.equipped.direction = player_angle()
    melee.equipped.x = player.x
    melee.equipped.y = player.y
  end
end