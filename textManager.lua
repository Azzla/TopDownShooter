local Typo = require('libs/Typo/typo')
Class = require('libs/floating-text/class')
require('libs/floating-text/effects/PopupText')
require('libs/floating-text/effects/PopupTextManager')
local gPopupManager = PopupTextManager()

local TextManager = {}
TextManager.timer = globalTimer.new()

local promptsRan = {
  annihilate = false,
  annihilateRect = true,
  drops = false
}

local alpha = { a = 1 }
local target = { a = 0 }
local flag = false
local textAlphaTween = tween.new(.5, alpha, target)

function TextManager.update(dt, game)
  Typo.update(dt)
  gPopupManager:update(dt)
  TextManager.timer:update(dt)
  
  if game.isDespawning then
    if alpha.a <= 1 and flag then
      textAlphaTween:update(dt)
      if alpha.a == 0 then flag = false end
    end
    if alpha.a >= 0 and not flag then
      textAlphaTween:update(-dt)
      if alpha.a == 1 then flag = true end
    end
  elseif not game.isDespawning and alpha.a ~= 1 then alpha.a = 1 end
end

function TextManager.drawGame()
  gPopupManager:render()
end

function TextManager.drawUI(o,o2,oB,oR,oXC,oYC)
  TextManager.introText(oXC, o2)
  
  if promptsRan.drops then
    Typo.draw(oR - 75, oB - 10, alpha.a)
    love.graphics.setColor(1,1,1,1)
  end
end

function TextManager.playerDmgPopup(x, y, z)
  gPopupManager:addPopup(
  {
      text = '-'..tostring(z.damage),
      font = pixelFont,
      color = {r = 1, g = .5, b = .5, a = 1},
      x = x,
      y = y,
      scaleX = .2 + z.damage/50,
      scaleY = .2 + z.damage/50,
      blendMode = 'add',
      fadeOut = {start = .5, finish = .7},
      dX = math.random(-8,8),
      dY = math.random(-20,-30),
      duration = .7
  })
end

function TextManager.bulletDmgPopup(damage, z)
  local dur = math.min(1, math.max(.4, damage/8))
  gPopupManager:addPopup(
  {
      text = tostring(damage),
      font = pixelFont,
      color = {r = 1, g = 1, b = 1, a = 1},
      x = z.x + math.random(-10,10),
      y = z.y,
      scaleX = .3 + math.min(damage/66, 1),
      scaleY = .3 + math.min(damage/66, 1),
--      blendMode = 'add',
      fadeOut = {start = dur - .1, finish = dur},
      dX = math.random(-8,8),
      dY = math.random(-20,-30),
      duration = dur
  })
end

function TextManager.grenadeDmgPopup(g, z)
  gPopupManager:addPopup(
  {
      text = tostring(g.damage),
      font = pixelFont,
      color = {r = .8, g = .1, b = 0, a = 1},
      x = z.x + math.random(-10,10),
      y = z.y,
      scaleX = .5,
      scaleY = .5,
      blendMode = 'add',
      fadeOut = {start = .5, finish = .7},
      dX = math.random(-5,5),
      dY = -20,
      duration = .7
  })
end

function TextManager.collectCoinPopup(x, y, str)
  gPopupManager:addPopup(
  {
      text = '+'..str,
      font = pixelFont,
      color = {r = 1, g = 1, b = .1, a = 1},
      x = x,
      y = y,
      scaleX = .35,
      scaleY = .35,
      blendMode = 'add',
      fadeOut = {start = .3, finish = .4},
      dX = 0,
      dY = -10,
      duration = .4
  })
end

function TextManager.collectXPPopup(x, y, str)
  gPopupManager:addPopup(
  {
      text = '+'..str,
      font = pixelFont,
      color = {r = 1, g = .1, b = 1, a = 1},
      x = x,
      y = y,
      scaleX = .35,
      scaleY = .35,
      blendMode = 'add',
      fadeOut = {start = .3, finish = .4},
      dX = math.random(-10,10),
      dY = math.random(-10,10),
      duration = .4
  })
end

function TextManager.genericPopup(x, y, str)
  gPopupManager:addPopup(
  {
      text = str,
      font = pixelFont,
      color = {r = 1, g = 1, b = 1, a = 1},
      x = x - 10,
      y = y - 5,
      scaleX = .6,
      scaleY = .6,
      fadeOut = {start = .7, finish = 1},
      dX = math.random(-5,5),
      dY = -20,
      duration = 1
  })
end


function TextManager.introText(oXC, o2)
  if not promptsRan.annihilate then
    local time = 3
    local index = Typo.new("ANNIHILATE.", time, 0.1, 500, 'center', 1.5, pixelFont, { 255, 255, 255 })
    
    TextManager.timer:after(time, function()
      Typo.kill(index)
      promptsRan.annihilateRect = false
    end)
  
    promptsRan.annihilate = true
  end
  
  if promptsRan.annihilateRect then
    love.graphics.setColor(0,0,0,.7)
    love.graphics.rectangle('fill', oXC - 100, o2 + 55, 200, 28)
    Typo.draw(oXC - 375, o2 + 60, 1)
    love.graphics.setColor(1,1,1,1)
  end
end

function TextManager.dropsDespawning(time)
  local index = Typo.new("Round Complete...", time, 0.01, 500, 'left', .5, pixelFont, { 255, 255, 255 })
  
  promptsRan.drops = true
  TextManager.timer:after(time, function()
    Typo.kill(index)
    promptsRan.drops = false
  end)

  return index
end

function TextManager.cancel(index)
  TextManager.timer:clear()
  Typo.kill(index)
  promptsRan.drops = false
end

return TextManager