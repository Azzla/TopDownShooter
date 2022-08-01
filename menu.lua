local menuButtonManager = require('buttonManager')

menu = {}
menu.background = love.graphics.newImage('sprites/ui/mainMenu.png')
menu.button = love.graphics.newImage('sprites/ui/UIBox1.png')
menu.buttonHover = love.graphics.newImage('sprites/ui/UIBox1Hover.png')
menu.buttonScale = 8

local menuBtnsDrawn = false
local backBtnDrawn = false

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

function mainMenu(ret1, ret2)
  backBtnDrawn = false
  
  love.graphics.draw(menu.background, 0, 0, nil, screen_width / menu.background:getWidth(), screen_height / menu.background:getHeight())

  if not menuBtnsDrawn then
    menuButtonManager.clear()
    for i=1,#menuBtnFunctions do
      menuButtonManager.new(32, screen_height - (128 * i), menuBtnFunctions[#menuBtnFunctions + 1 - i],
      menu.button, menu.buttonHover, menu.buttonScale, soundFX.collectCoin)
    end
    menuBtnsDrawn = true
  end

  menuButtonManager.draw(ret1, ret2)
  
  --Text
  love.graphics.print("PLAY", 190, screen_height - (117 * 3), nil, 3, 3)
  love.graphics.print("HELP", 190, screen_height - (112 * 2), nil, 3, 3)
  love.graphics.print("QUIT", 190, screen_height - (96 * 1), nil, 3, 3)

  love.graphics.draw(reticle, ret1, ret2,nil,4,4,3,3)
end

function helpScreen(ret1, ret2)
  menuBtnsDrawn = false
  
  love.graphics.draw(menu.background, 0, 0, nil, screen_width / menu.background:getWidth(), screen_height / menu.background:getHeight())
  love.graphics.draw(love.graphics.newImage('sprites/ui/UIShop.png'), screen_width / 2, screen_height / 2, nil, 6, 6, 112, 78)
  --tips
  love.graphics.print("Movement: WASD", screen_width / 2 - 600, screen_height / 2 - 300, nil, 3, 3)
  love.graphics.print("Shoot: Mouse1", screen_width / 2 - 600, screen_height / 2 - 200, nil, 3, 3)
  love.graphics.print("Reload: R", screen_width / 2 - 600, screen_height / 2 - 100, nil, 3, 3)
  love.graphics.print("Dash: Spacebar", screen_width / 2 - 600, screen_height / 2, nil, 3, 3)
  love.graphics.print("Shop: Shift", screen_width / 2 - 600, screen_height / 2 + 100, nil, 3, 3)
  love.graphics.print("Pause: Escape", screen_width / 2 - 600, screen_height / 2 + 200, nil, 3, 3)
  love.graphics.print("Quit Game: End", screen_width / 2 - 600, screen_height / 2 + 300, nil, 3, 3)

  if not backBtnDrawn then
    menuButtonManager.clear()
    menuButtonManager.new(32, screen_height - 128,function() round.gameState = 4 end,
    menu.button, menu.buttonHover, menu.buttonScale, soundFX.collectCoin)
  
    backBtnDrawn = true
  end

  menuButtonManager.draw(ret1, ret2)
  love.graphics.print("BACK", 190, screen_height - 95, nil, 3, 3)
  love.graphics.draw(reticle, ret1, ret2,nil,4,4,3,3)
end