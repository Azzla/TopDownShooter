--libs
Gamestate = require('libs/hump/gamestate')
require('libs/slam')
globalTimer = require('libs/hump/timer')
tween = require('libs/tween/tween')
anim8 = require('libs/anim8/anim8')
HC = require('libs/hardoncollider')
require('sounds')
soundFX:loadSoundFX()
require('shaders')

love.graphics.setDefaultFilter("nearest", "nearest")
local menu = require('menu')
local game = require('game')
local pause = {}
local gameOver = {}

function love.load()
  love.window.setMode(0, 0)
  SCREEN_W = love.graphics.getWidth()
  SCREEN_H = love.graphics.getHeight()
  
  Gamestate.registerEvents()
  Gamestate.push(menu, game)
  
  --font
  pixelFont = love.graphics.newFont('fonts/Minecraft.ttf', 16)
  love.graphics.setFont(pixelFont)
  pixelFont:setFilter( "nearest", "nearest" )

  reticle = love.graphics.newImage('sprites/cursor.png')
  love.mouse.setVisible(false)
end

function love.update(dt)
  gameMusic(dt, game)
  globalTimer.update(dt)
end

function love.draw()
  ----------------
  --collisionDebug()
  ----------------
end

function cameraCoordinates(c, scale)
  local o,o2 = c:worldCoords(0,0)
  local oB = o2 + (SCREEN_H / scale)
  local oR = o + (SCREEN_W / scale)
  local oXC, oYC = c:worldCoords(SCREEN_W/2, SCREEN_H/2)
  
  return o,o2,oB,oR,oXC,oYC
end

-------------------------
--------UTILITIES--------
-------------------------
function collisionDebug()
  if Gamestate.current() == game then
    love.graphics.setColor(1,0,0,1)
    for i,b in ipairs(bullets) do
      b.coll:draw('line')
    end
    for i,z in ipairs(zombies) do
      z.coll:draw('line')
    end
    for i,g in ipairs(grenades) do
      g.coll:draw('line')
    end
    player:draw('line')
    love.graphics.setColor(1,1,1,1)
  end
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function true_randomID(value)
  return value / math.random(99999,999999)
end

function offsetXY(x, y, pAngle)
  local handDistance = math.sqrt(x^2 + y^2)
  local handAngle    = pAngle + math.atan2(y, x)
  local handOffsetX  = handDistance * math.cos(handAngle)
  local handOffsetY  = handDistance * math.sin(handAngle)
  
  return handOffsetX,handOffsetY
end

function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

function player_angle()
  local a,b = cam:cameraCoords(cam:mousePosition())
  local c,d = cam:cameraCoords(player.x, player.y)
  return math.atan2(d - b, c - a) - math.pi/2
end

function zombie_angle(enemy)
  local a,b = cam:cameraCoords(enemy.x, enemy.y)
  local c,d = cam:cameraCoords(player.x, player.y)
  return math.atan2(d - b, c - a) + math.pi/2
end

function grenade_angle(g, z)
  local a,b = cam:cameraCoords(g.x, g.y)
  local c,d = cam:cameraCoords(z.x, z.y)
  return math.atan2(d - b, c - a) + math.pi/2
end

function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

function linInterp(min,max,fraction)
  return ((max - min) * fraction + min)
end