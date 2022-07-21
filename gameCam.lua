cameraFile = require('hump-master/camera')
cam = cameraFile()
cam:zoom(zoom_factor)
cam:lookAt(player.x, player.y)
camSmoothing = cam.smooth.damped(8)

camTimer = globalTimer.new()
cameraDamaged = false
mag = 1

camOrigin,camOrigin2 = cam:worldCoords(0,0)
camOriginMax,camOrigin2Max = cam:worldCoords(map_width,map_height)

function updateCameraTimers(dt)
  camTimer:update(dt)
end

function cameraHandler(x, y, dt)
  local wvw, wvh = screen_width/(2*cam.scale), screen_height/(2*cam.scale)
  
  if round.gameState == 2 then
    cam:lockPosition(x, y, camSmoothing)
    
    --screen shake
    if cameraDamaged then
      cam.x = cam.x + math.random(-mag,mag)
      cam.y = cam.y + math.random(-mag,mag)
    end
    
    cam.x = math.max(cam.x, 0 + wvw)
    cam.x = math.min(cam.x, map_width - wvw)
    cam.y = math.max(cam.y, 0 + wvh)
    cam.y = math.min(cam.y, map_height - wvh)
  end
end