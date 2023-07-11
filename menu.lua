local menuButtonManager = require('buttonManager')
local menu = {}

function menu:init()
  self.background = love.graphics.newImage('sprites/ui/mainMenu.png')
  self.bgWidth = self.background:getWidth()
  self.bgHeight = self.background:getHeight()
  self.button = love.graphics.newImage('sprites/ui/UIBox1.png')
  self.buttonHover = love.graphics.newImage('sprites/ui/UIBox1Hover.png')
  self.buttonScale = 8
  self.menuBtnsDrawn = false
  self.backBtnDrawn = false
  
  self.btnFunctions = {
    function()
      Gamestate.switch(self.game)
    end,
    function()
      return
    end,
    function()
      love.event.quit()
    end,
  }
end

function menu:draw()
  local screen_width = love.graphics.getWidth()
  local screen_height = love.graphics.getHeight()
  local ret1, ret2 = love.mouse:getPosition()
  
  self.backBtnDrawn = false
  love.graphics.draw(self.background, 0, 0, nil, screen_width / self.bgWidth, screen_height / self.bgHeight)

  if not self.menuBtnsDrawn then
    for i=1,#self.btnFunctions do
      menuButtonManager.new(32, screen_height - (128 * i), self.btnFunctions[#self.btnFunctions + 1 - i],
      self.button, self.buttonHover, self.buttonScale)
    end
    self.menuBtnsDrawn = true
  end

  menuButtonManager.draw(ret1, ret2)
  
  --Text
  love.graphics.print("PLAY", 190, screen_height - (117 * 3), nil, 3, 3)
  love.graphics.print("HELP", 190, screen_height - (112 * 2), nil, 3, 3)
  love.graphics.print("QUIT", 190, screen_height - (96 * 1), nil, 3, 3)

  love.graphics.draw(reticle, ret1, ret2,nil,4,4,3,3)
end

function menu:enter(previous, game)
  if not self.game then self.game = game end
end

function menu:leave()
  menuButtonManager.clear()
  self.menuBtnsDrawn = false
  self.backBtnDrawn = false
end

return menu