healthbars = {}
healthbarSprite = love.graphics.newImage('sprites/healthbar.png')

function spawnHealthBar(HP, x, y, zomHB)
  zomHB.x = x
  zomHB.y = y
  zomHB.totalHealth = HP
  zomHB.health = zomHB.totalHealth
  zomHB.sprite = healthbarSprite
  zomHB.grid = anim8.newGrid(12, 3, 132, 3)
  zomHB.animation = anim8.newAnimation(zomHB.grid("1-11", 1), 1)
  zomHB.isPlayer = false
  zomHB.isHidden = true
  
  table.insert(healthbars, zomHB)
  
  return zomHB
end
  
function healthBarUpdate(x, y, hb, animation, health, totalHealth)
  hb.x = x
  hb.y = y - 6
  
  if health >= totalHealth then
    animation:gotoFrame(11)
  elseif health >= .89*totalHealth then
    animation:gotoFrame(10)
  elseif health >= .79*totalHealth then
    animation:gotoFrame(9)
  elseif health >= .69*totalHealth then
    animation:gotoFrame(8)
  elseif health >= .59*totalHealth then
    animation:gotoFrame(7)
  elseif health >= .49*totalHealth then
    animation:gotoFrame(6)
  elseif health >= .39*totalHealth then
    animation:gotoFrame(5)
  elseif health >= .29*totalHealth then
    animation:gotoFrame(4)
  elseif health >= .19*totalHealth then
    animation:gotoFrame(3)
  elseif health <= .9*totalHealth and health > 0 then
    animation:gotoFrame(2)
  elseif health <= 0 then
    animation:gotoFrame(1)
  end
end