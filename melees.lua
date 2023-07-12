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
melee.weapons.katana.dmg = 20
melee.weapons.katana.swipeTime = 1.04


function meleeAttack()
  canShoot = false
  melee.equipped = melee.weapons.katana
  melee.equipped.animation:gotoFrame(1)
  melee.equipped.direction = player_angle()
  melee.active = true
  love.audio.play(soundFX.slash)
  
  melee.timer:after(melee.equipped.swipeTime, function()
    melee.active = false
    canShoot = true
  end)
end

function drawMelee()
  if melee.active then
    melee.equipped.animation:draw(melee.equipped.sheet, melee.equipped.x, melee.equipped.y, melee.equipped.direction, 1, 1, melee.equipped.offsX, melee.equipped.offsY)
  end
end

function updateMelee(dt)
  melee.timer:update(dt)
  
  if melee.active then
    melee.equipped.animation:update(dt)
    melee.equipped.direction = player_angle()
    melee.equipped.x = player.x
    melee.equipped.y = player.y
  end
end