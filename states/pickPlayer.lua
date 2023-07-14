local PickPlayer = {}

function PickPlayer:init()
  self.background = function() love.graphics.rectangle('fill', 0, 0, SCREEN_W, SCREEN_H) end
  self.bgColor = { rgb(63), rgb(40), rgb(50), 1 }
  self.uiBox = love.graphics.newImage('sprites/ui/UIBoxChar.png')
  self.uiBoxHot = love.graphics.newImage('sprites/ui/UIBoxCharHover.png')
  self.s = 8
  self.characters = require('dicts/characterDict')
  self.buttonManager = require('buttonManager')
  self.btnFunctions = {
    function() Gamestate.switch(self.game, self.characters.iron) end,
    function() Gamestate.switch(self.game, self.characters.chrome) end,
    function() Gamestate.switch(self.game, self.characters.osmium) end,
    function() Gamestate.switch(self.game, self.characters.titanium) end
  }
end

function PickPlayer:draw()
  local ret1, ret2 = love.mouse:getPosition()
  
  love.graphics.setColor(self.bgColor)
  self.background()
  love.graphics.setColor(1,1,1,1)
  love.graphics.printf("Choose Character", SCREEN_W/3.5, 128, 300, 'left', nil, self.s, self.s)
  love.graphics.line(0, 256, SCREEN_W, 256)
  
  self.buttonManager.draw(ret1, ret2)
  self.buttonManager.drawSprites()
  
  love.graphics.draw(reticle, ret1, ret2,nil,4,4,3,3)
end

function PickPlayer:enter(previous, game)
  if not self.menu then self.menu = previous end
  if not self.game then self.game = game end
  
  --create buttons
  for i=1,#self.btnFunctions do
    local x,y = 64 + (256 * i), 512
    local sprite = self.characters[i].sprite
    self.buttonManager.new(x, y, self.btnFunctions[i],
    self.uiBox, self.uiBoxHot, self.s, soundFX.charSelect, soundFX.btnHover)
  
    self.buttonManager.addSprite(x + 40, y + 50, sprite, self.s)
  end
end

function PickPlayer:keypressed(key)
  if key == "escape" then Gamestate.switch(self.menu)
  elseif key == "end" then love.event.quit() end
end

function PickPlayer:leave()
  self.buttonManager.clear()
end

return PickPlayer