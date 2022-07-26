cameraFile = require('libs/hump/camera')
cam = cameraFile()
cam:zoom(guns.equipped.zoomFactor)
cam:lookAt(player.x, player.y)
camSmoothing = cam.smooth.damped(8)

camTimer = globalTimer.new()
local cameraDamaged = false
local magnitude = 1

camOrigin,camOrigin2 = cam:worldCoords(0,0)
camOriginMax,camOrigin2Max = cam:worldCoords(map_width,map_height)

currentZoom = { zoom = guns.equipped.zoomFactor }
targetZoom = { zoom = guns.equipped.zoomFactor }
camTween = tween.new(.25, currentZoom, targetZoom)

function updateCameraTimers(dt)
  camTimer:update(dt)
  camTween:update(dt)
end

function cameraHandler(x, y, dt)
  local wvw, wvh = screen_width/(2*guns.equipped.zoomFactor), screen_height/(2*guns.equipped.zoomFactor)
  
  if round.gameState == 2 then
    cam:lockPosition(x, y, camSmoothing)
    
    --screen shake
    if cameraDamaged then
      cam.x = cam.x + math.random(-magnitude,magnitude)
      cam.y = cam.y + math.random(-magnitude,magnitude)
    end
    
    cam.x = math.max(cam.x, 0 + wvw)
    cam.x = math.min(cam.x, map_width - wvw)
    cam.y = math.max(cam.y, 0 + wvh)
    cam.y = math.min(cam.y, map_height - wvh)
  end
end

function screenShake(time, mag)
  magnitude = mag
  cameraDamaged = true
  camTimer:after(time, function() cameraDamaged = false end)
end

function switchZoom(prevScale, scale)
  local offset = currentZoom.zoom - prevScale
  
  currentZoom = { zoom = prevScale + offset }
  targetZoom = { zoom = scale }
  camTween = tween.new(.25, currentZoom, targetZoom)
end