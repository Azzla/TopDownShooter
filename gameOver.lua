gameOver = {}

gameOver.graphic = love.graphics.newImage('sprites/gameOver.png')

function gameOverScreen()
  love.graphics.draw(gameOver.graphic, 0, 0)
end