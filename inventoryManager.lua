local Inventory = {}

function Inventory.init(keypressed)
  local inventory = {
    sprite_full = love.graphics.newImage('sprites/ui/inv_full.png'),
    sprite_select = love.graphics.newImage('sprites/ui/inv_select.png'),
    cel_w = 16,
    inv_w = 160,
    scale = 1,
    size = 10,
    active_slot = 1
  }
  
  function inventory:update(dt)
    
  end
  
  function inventory:draw(origX, origY)
    love.graphics.draw(self.sprite_full, origX - self.inv_w/2, origY, nil, self.scale, self.scale)
    love.graphics.draw(self.sprite_select, origX - self.inv_w/2 + ((self.active_slot-1) * self.cel_w), origY, nil, self.scale, self.scale)
  end
  
  --keybinds
  for i=1,10 do
    table.insert(keypressed, function(key, scancode)
      if tonumber(key) == i then
        inventory.active_slot = i
      elseif tonumber(key) == 0 then
        inventory.active_slot = 10
      end
    end)
  end
  
  function love.wheelmoved( x, y )
    if y > 0 then
      inventory.active_slot = inventory.active_slot + 1
    elseif y < 0 then
      inventory.active_slot = inventory.active_slot - 1
    end
    if inventory.active_slot < 1 then inventory.active_slot = 1 end
    if inventory.active_slot > 10 then inventory.active_slot = 10 end
  end
  
  return inventory
end

return Inventory