local menu = {}

function menu:init()
  self.background = function() love.graphics.rectangle('fill', 0, 0, SCREEN_W, SCREEN_H) end
  self.bgColor = { rgb(63), rgb(40), rgb(50), 1 }
  self.button = love.graphics.newImage('sprites/ui/UIBox1.png')
  self.buttonHover = love.graphics.newImage('sprites/ui/UIBox1Hover.png')
  self.buttonScale = 8
  self.buttonManager = require('buttonManager')
  self.btnFunctions = {
    function()
      Gamestate.switch(self.picker, self.game)
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
  local ret1, ret2 = love.mouse:getPosition()
  love.graphics.setColor(self.bgColor)
  self.background()
  love.graphics.setColor(1,1,1,1)
  
  self.buttonManager.draw(ret1, ret2)
  
  --Text
  love.graphics.print("PLAY", 190, SCREEN_H - (117 * 3), nil, 3, 3)
  love.graphics.print("HELP", 190, SCREEN_H - (112 * 2), nil, 3, 3)
  love.graphics.print("QUIT", 190, SCREEN_H - (96 * 1), nil, 3, 3)

  love.graphics.draw(reticle, ret1, ret2,nil,4,4,3,3)
end

function menu:enter(previous, picker, game)
  if not self.picker then self.picker = picker end
  if not self.game then self.game = game end
  
  --create buttons
  for i=1,#self.btnFunctions do
    self.buttonManager.new(32, SCREEN_H - (128 * i), self.btnFunctions[#self.btnFunctions + 1 - i],
    self.button, self.buttonHover, self.buttonScale, soundFX.charSelect, soundFX.btnHover)
  end
end

function menu:leave()
  self.buttonManager.clear()
end

return menu