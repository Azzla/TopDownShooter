local BotManager = {}

function BotManager:init(player)
  self.sprite = love.graphics.newImage('sprites/characters/titanium.png')
  self.player = player
  self.deltaX = 1
  self.deltaY = 1
end

function BotManager:draw()
  local x,y = self:deltaXY(self.player)
  love.graphics.draw(self.sprite, x, y)
end

function BotManager:deltaXY(player)
  local angle = player:angle()
  local deltaXrotated = self.deltaX * math.cos(angle) - self.deltaY * math.sin(angle)
  local deltaYrotated = self.deltaX * math.sin(angle) + self.deltaY * math.cos(angle)
  
  local x,y = cam:cameraCoords(deltaXrotated + player.x, deltaYrotated + player.y)
  return x,y
end

return BotManager