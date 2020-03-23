player = {}

player.x = love.graphics.getWidth()/2
player.y = love.graphics.getHeight()/2
player.sprite = love.graphics.newImage('sprites/robotWalk.png')
player.frame = love.graphics.newImage('sprites/Robot.png')
player.speed = 0
player.position = {player.x, player.y}
player.grid = anim8.newGrid(16, 16, 128, 16)
player.animation = anim8.newAnimation(player.grid("1-8",1), 0.08)

function playerUpdate(dt)
  if love.keyboard.isDown("a") then
    player.x = player.x - player.speed*dt
  end
  if love.keyboard.isDown("d") then
    player.x = player.x + player.speed*dt
  end
  if love.keyboard.isDown("w") then
    player.y = player.y - player.speed*dt
  end
  if love.keyboard.isDown("s") then
    player.y = player.y + player.speed*dt
  end
  player.speed = 60 + shop.skills.speed
end

function walkAnimation(dt)
  if love.keyboard.isDown('w','a','s','d') then
    player.animation:update(dt)
  else
    player.animation:gotoFrame(1)
  end
end