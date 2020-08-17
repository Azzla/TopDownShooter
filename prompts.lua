prompts = {}

prompts.empty = love.graphics.newImage('sprites/prompts/Empty.png')
prompts.wasd = love.graphics.newImage('sprites/prompts/WASD.png')
prompts.holdMouse = love.graphics.newImage('sprites/prompts/HoldMouse.png')
prompts.shiftShop = love.graphics.newImage('sprites/prompts/ShiftShop.png')
prompts.spacebar = love.graphics.newImage('sprites/prompts/Spacebar.png')

prompts.alpha = {}
prompts.alpha.alpha = 1

promptTimer = globalTimer.new()

local target = {}
target.alpha = 0
promptTween = tween.new(4, prompts.alpha, target, tween.easing.inQuart)

function drawPrompt(image, x , y, alpha)
  love.graphics.setColor(255, 255, 255, alpha)
  love.graphics.draw(image, x, y)
  love.graphics.setColor(255, 255, 255, 1)
end

function updatePromptAlpha(dt)
  if round.gameState == 2 then
    if prompts.alpha.alpha ~= target.alpha then
      promptTween:update(dt)
    else
      if currentPrompt ~= prompts.spacebar then
        changePrompt()
      end
    end
  end
end

function changePrompt()
  if currentPrompt == prompts.wasd then
    currentPrompt = prompts.holdMouse
  elseif currentPrompt == prompts.holdMouse then
    currentPrompt = prompts.shiftShop
  elseif currentPrompt == prompts.shiftShop then
    currentPrompt = prompts.spacebar
  end
  promptTween:reset()
end