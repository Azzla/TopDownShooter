local TextManager = require('textManager')

exp_instances = {}
exp = {}
exp.currentLevel = 1
exp.levelMulti = 1.04 --how much the xp required for level up increases per level
exp.currentXP = 0
exp.expRequirement = 11 -- how much xp is required at start
exp.value = 10

local expSprite = love.graphics.newImage('sprites/coins/exp.png')
local expSheet = love.graphics.newImage('sprites/coins/exp-sheet.png')
local collectionDist = 6

local function rgb(integer)
  return integer/255
end

xpTweenMax = 50
expBarTweenCurr =
{
  w = 0,
  h = 3
}
expBarTweenTarget =
{
  w = xpTweenMax * exp.currentXP,
  h = 3
}
local xpTween = tween.new(.4, expBarTweenCurr, expBarTweenTarget)


function updateXP(dt, magnet)
  xpTween:update(dt)
  for i,x in ipairs(exp_instances) do
    if x.anim then x.anim:update(dt) end
    local expDistance = distanceBetween(x.x, x.y, player.x, player.y)
    
    if expDistance > collectionDist and expDistance < (8 * magnet) then
      x.x = x.x + math.cos(zombie_angle_wrld(x)) * x.speed * dt
      x.y = x.y + math.sin(zombie_angle_wrld(x)) * x.speed * dt
    elseif expDistance < collectionDist then
      exp.currentXP = exp.currentXP + exp.value
      
      if exp.currentXP >= exp.expRequirement then levelUp() end
      
      local prevTarget = expBarTweenTarget.w
      expBarTweenTarget.w = xpTweenMax * (exp.currentXP / exp.expRequirement)
      expBarTweenCurr.w = prevTarget
      xpTween = tween.new(.1, expBarTweenCurr, expBarTweenTarget)
      
      TextManager.collectXPPopup(x.x, x.y, tostring(exp.value))
      x.collected = true
      love.audio.play(soundFX.collectCoin)
    end
  end
  
  for i=#exp_instances,1,-1 do
    local xp = exp_instances[i]
    if xp.collected == true then
      table.remove(exp_instances, i)
    end
  end
end

function levelUp()
  exp.currentXP = exp.currentXP - exp.expRequirement -- carry over leftover xp to next level
  exp.expRequirement = exp.expRequirement * exp.levelMulti
  exp.currentLevel = exp.currentLevel + 1
end

function drawXP()
  for i,x in ipairs(exp_instances) do
    if x.anim then
      x.anim:draw(x.sheet, x.x, x.y, nil, nil, nil, 2, 2)
    else
      love.graphics.draw(x.sprite, x.x, x.y, nil, nil, nil, 2, 2)
    end
  end
end

function drawXPBar(x,y,w,h)
  love.graphics.setColor(rgb(175), rgb(191), rgb(210), 1)
  love.graphics.rectangle('fill',x,y,w,h)
  love.graphics.setColor(1,1,1)
end

function spawnXP(obj)
  local xp = {}
  
  xp.x = obj.x + math.random(-obj.goldSpawn, obj.goldSpawn)
  xp.y = obj.y + math.random(-obj.goldSpawn, obj.goldSpawn)
  xp.collected = false
  xp.sprite = expSprite
  xp.sheet = expSheet
  xp.speed = math.random(90, 170)
  xp.grid = anim8.newGrid(3,6,18,6)
  xp.anim = anim8.newAnimation(xp.grid('1-6', 1), .06)
  
  table.insert(exp_instances, xp)
end

function spawnXPReward(zombie)
  spawnXP(zombie) --TODO might adjust
end