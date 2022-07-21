gameOver = {}

gameOver.graphic = love.graphics.newImage('sprites/gameOver.png')

function gameOverScreen()
  love.graphics.draw(gameOver.graphic, 0, 0, nil, love.graphics.getWidth() / gameOver.graphic:getWidth(), love.graphics.getHeight() / gameOver.graphic:getHeight())
end