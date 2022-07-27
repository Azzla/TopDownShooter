local ButtonManager = {}
local buttons = {}
local oldmousedown = false

function ButtonManager.new(x, y, fn, s, sH, scale, clickSound)
  local button = {}
  button.x = x
  button.y = y
  button.s = scale or 1
  button.sprite = s
  button.spriteHot = sH
  button.fn = fn
  button.clickSound = clickSound
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
      love.graphics.draw(b.spriteHot, b.x, b.y, nil, b.s, b.s)
    else
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

function ButtonManager.getButtons() return buttons end
function ButtonManager.remove(index) table.remove(buttons, index) end
function ButtonManager.clear() buttons = {} end

return ButtonManager