local ButtonManager = {}
local buttons = {}
local sprites = {}
local oldmousedown = false

function ButtonManager.new(x, y, fn, s, sH, scale, clickSound, hoverSound)
  local button = {}
  button.x = x
  button.y = y
  button.s = scale or 1
  button.sprite = s
  button.spriteHot = sH
  button.fn = fn
  button.clickSound = clickSound or nil
  button.hoverSound = hoverSound or nil
  button.hoverPlayed = false
  button.clicked = 0
  button.id = #buttons+1
  
  table.insert(buttons, button)
end

function ButtonManager.draw(ret1, ret2)
  for i,b in ipairs(buttons) do
    --check if hovering
    local isHot = ret1 > b.x and ret1 < b.x + b.sprite:getWidth() * b.s and 
                  ret2 > b.y and ret2 < b.y + b.sprite:getHeight() * b.s
    --draw sprite
    if isHot then
      if b.hoverSound and not b.hoverPlayed then
        b.hoverPlayed = true
        love.audio.play(b.hoverSound)
      end
      love.graphics.draw(b.spriteHot, b.x, b.y, nil, b.s, b.s)
    else
      b.hoverPlayed = false
      love.graphics.draw(b.sprite, b.x, b.y, nil, b.s, b.s)
    end
    --check for click
    if love.mouse.isDown(1) and not oldmousedown and isHot then
      if b.clickSound then love.audio.play(b.clickSound) end
      b.fn()
      b.clicked = b.clicked + 1
    end
  end
  oldmousedown = love.mouse.isDown(1)
end

function ButtonManager.addSprite(x,y,sprite,scale)
  local s = {}
  s.x = x
  s.y = y
  s.sprite = sprite
  s.scale = scale
  
  table.insert(sprites, s)
end

function ButtonManager.drawSprites()
  for i,s in ipairs(sprites) do
    love.graphics.draw(s.sprite, s.x, s.y, nil, s.scale, s.scale)
  end
end

function ButtonManager.getButtons() return buttons end
function ButtonManager.remove(index) table.remove(buttons, index) end
function ButtonManager.clear()
  buttons = {}
  sprites = {}
end

return ButtonManager