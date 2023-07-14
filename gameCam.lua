cameraFile = require('libs/hump/camera')
cam = cameraFile()
--cam:lookAt(player.x, player.y)
local camSmoothing = cam.smooth.damped(8)

local camTimer = globalTimer.new()
local cameraDamaged = false
local magnitude = 1

local camOrigin,camOrigin2 = cam:worldCoords(0,0)
local camOriginMax,camOrigin2Max = cam:worldCoords(map_width,map_height)

currentZoom = { zoom = 7 }
local targetZoom = { zoom = 7 }
local camTween = tween.new(.25, currentZoom, targetZoom)

function updateCameraTimers(dt)
  camTimer:update(dt)
  camTween:update(dt)
end

function cameraHandler(dt, x, y, zoom)
  updateCameraTimers(dt)
  local wvw, wvh = SCREEN_W/(2*zoom), SCREEN_H/(2*zoom)
  
  cam:lockPosition(x, y, camSmoothing)
  
  cam.x = math.max(cam.x, 0 + wvw)
  cam.x = math.min(cam.x, map_width - wvw)
  cam.y = math.max(cam.y, 0 + wvh)
  cam.y = math.min(cam.y, map_height - wvh)
  
  --screen shake
  if cameraDamaged then
    cam.x = cam.x + math.random(-magnitude,magnitude)
    cam.y = cam.y + math.random(-magnitude,magnitude)
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