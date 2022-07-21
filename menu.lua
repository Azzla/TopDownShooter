menu = {}
menu.background = love.graphics.newImage('sprites/mainMenu.png')
menu.button = love.graphics.newImage('sprites/UIBox1.png')
menu.buttonHover = love.graphics.newImage('sprites/UIBox1Hover.png')
oldmousedown = false

menuButtons = {}
menuBtnsDrawn = false
menuBtnFunctions = {
  function()
    round.gameState = 2
  end,
  function()
    round.gameState = 6
  end,
  function()
    love.event.quit()
  end,
}

backBtnDrawn = false
function helpScreen()
  menuBtnsDrawn = false
  mouseX,mouseY = love.mouse:getPosition()
  love.graphics.draw(menu.background, 0, 0, nil, screen_width / menu.background:getWidth(), screen_height / menu.background:getHeight())
  love.graphics.draw(love.graphics.newImage('sprites/UIShop.png'), screen_width / 2, screen_height / 2, nil, nil, nil, 112, 78)

  if not backBtnDrawn then
    menuButtons = {}
    newButton(32, screen_height - 128,
      function()
        round.gameState = 4
      end)
    backBtnDrawn = true
  end

  drawMenuButtons()
  love.graphics.print("BACK", 190, screen_height - 95, nil, 3, 3)
  love.graphics.draw(reticle, mouseX, mouseY,nil,4,4,3,3)
end

function mainMenu()
  backBtnDrawn = false
  mouseX,mouseY = love.mouse:getPosition()
  love.graphics.draw(menu.background, 0, 0, nil, screen_width / menu.background:getWidth(), screen_height / menu.background:getHeight())

  if not menuBtnsDrawn then
    menuButtons = {}
    for i=1,#menuBtnFunctions do
      newButton(32, screen_height - (128 * i), menuBtnFunctions[#menuBtnFunctions + 1 - i])
    end
    menuBtnsDrawn = true
  end

  drawMenuButtons()
  --Btn Text
  love.graphics.print("PLAY", 190, screen_height - (117 * 3), nil, 3, 3)
  love.graphics.print("HELP", 190, screen_height - (112 * 2), nil, 3, 3)
  love.graphics.print("QUIT", 190, screen_height - (96 * 1), nil, 3, 3)

  love.graphics.draw(reticle, mouseX, mouseY,nil,4,4,3,3)
end

function newButton(x, y, fn)
  local button = {}
  button.x = x
  button.y = y
  button.sprite = menu.button
  button.spriteHot = menu.buttonHover
  button.fn = fn

  table.insert(menuButtons, button)
end

function drawMenuButtons()
  for i, button in ipairs(menuButtons) do
    --check if hovering
    local isHot = mouseX > button.x and mouseX < button.x + button.sprite:getWidth() * 8 and 
    mouseY > button.y and mouseY < button.y + button.sprite:getHeight() * 8
    --draw sprite
    if isHot then
      love.graphics.draw(button.spriteHot, button.x, button.y, nil, 8, 8)
    else
      love.graphics.draw(button.sprite, button.x, button.y, nil, 8, 8)
    end
    --check for click
    if love.mouse.isDown(1) and not oldmousedown and isHot then
      button.fn()
    end
  end
  oldmousedown = love.mouse.isDown(1)
end