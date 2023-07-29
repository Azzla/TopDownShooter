local pause = {}

function pause:update(dt)
  
end

function pause:draw()
  love.graphics.setShader(pauseShader)
  self.game:draw(true)
  love.graphics.setShader()
  
  love.graphics.printf("PAUSED", SCREEN_W/2, SCREEN_H/2, 1000, "left", nil, 16, 16)
end

function pause:enter(previous)
  if not self.game then self.game = previous end
end

function pause:keypressed(key)
  if key == "escape" or key == "p" then
    Gamestate.switch(self.game)
  end
end

return pause