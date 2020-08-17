energy = {}
energy.width = 0
energy.height = 3

local target = {}
target.width = 50
target.height = 3
dashTween = tween.new(2.7, energy, target)

function energyUpdate(dt)
  if round.gameState == 2 and energy.width ~= target.width then
    dashTween:update(dt)
  end
end

function drawEnergy(x,y,w,h)
  love.graphics.setColor(why(0), why(234), why(255), 1)
  love.graphics.rectangle('fill',x,y,w,h)
  love.graphics.setColor(1,1,1)
end

function why(integer)
  return integer/255
end