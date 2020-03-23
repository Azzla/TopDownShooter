healthbars = {}

function spawnHealthBar(isPlayer)
  local healthbar = {}
  healthbar.x = 0
  healthbar.y = 0
  healthbar.health = 100
  healthbar.sprite = love.graphics.newImage('sprites/healthbar.png')
  healthbar.grid = anim8.newGrid(12, 3, 132, 3)
  healthbar.animation = anim8.newAnimation(healthbar.grid("1-11", 1), 1)
  healthbar.isPlayer = isPlayer
  
  table.insert(healthbars, healthbar)
end

function healthBarUpdate(dt, location)
  for i,h in ipairs(healthbars) do
    h.x = location.x
    h.y = location.y - 15
    
    if h.health >= 100 then
      h.animation:gotoFrame(11)
    elseif h.health >= 89 then
      h.animation:gotoFrame(10)
    elseif h.health >= 79 then
      h.animation:gotoFrame(9)
    elseif h.health >= 69 then
      h.animation:gotoFrame(8)
    elseif h.health >= 59 then
      h.animation:gotoFrame(7)
    elseif h.health >= 49 then
      h.animation:gotoFrame(6)
    elseif h.health >= 39 then
      h.animation:gotoFrame(5)
    elseif h.health >= 29 then
      h.animation:gotoFrame(4)
    elseif h.health >= 10 then
      h.animation:gotoFrame(3)
    elseif h.health <= 9 and h.health > 0 then
      h.animation:gotoFrame(2)
    elseif h.health <= 0 then
      h.animation:gotoFrame(1)
    end
    
    for i,z in ipairs(zombies) do
      if distanceBetween(player.x,player.y,z.x,z.y) < 5 then
        z.dead = true
        h.health = h.health - z.damage
      end
    end
  
  end
end