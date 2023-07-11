local function rgb(integer)
  return integer/255
end

energy = {}
energy.width = 0
energy.height = 1

reloader = {}
reloader.width = 0
reloader.height = 3

local target = {}
target.width = 50
target.height = 3

local target2 = {}
target2.width = 15
target2.height = 1

dashTween = tween.new(2.7, energy, target2)
reloadTween = tween.new(guns.equipped.reload, reloader, target)

function energyUpdate(dt)
  if energy.width ~= target.width then
    dashTween:update(dt)
  end
  if reloader.width ~= target.width then
    reloadTween:update(dt)
  end
end

function drawEnergy(x,y,w,h, isRecharge)
  local alpha
  if isRecharge then alpha = 0 else alpha = 1 end
  
  love.graphics.setColor(rgb(240), rgb(240), rgb(240), alpha)
  love.graphics.rectangle('fill',x,y,w,h)
  love.graphics.setColor(1,1,1)
end

function drawReload(x,y,w,h)
  love.graphics.setColor(rgb(0), rgb(234), rgb(255), 1)
  love.graphics.rectangle('fill',x,y,w,h)
  love.graphics.setColor(1,1,1)
end

function updateTweens()
  reloader.width = 0
  reloadTween = tween.new(guns.equipped.reload, reloader, target)
  reloadTween:set(99)
end