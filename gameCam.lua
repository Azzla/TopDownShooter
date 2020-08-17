cameraFile = require('hump-master/camera')
cam = cameraFile()
cam:zoom(5)
cam:lookAt(player.x, player.y)

camSmoothing = cam.smooth.damped(8)

function cameraHandler(x, y)
  cam:lockPosition(x, y, camSmoothing)
  local camX, camY = cam:position()
  if camX <= 192 then
    cam:lockX(192)
  elseif camX >= 1728 then
    cam:lockX(1728)
  end
  if camY <= 108 then
    cam:lockY(108)
  elseif camY >= 972 then
    cam:lockY(972)
  end
end