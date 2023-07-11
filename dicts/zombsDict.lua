local zombieTypes = {}
local zomAssets = {}
zomAssets.zombieFrame = love.graphics.newImage('sprites/zombies/zombie.png')
zomAssets.zombieSprite = love.graphics.newImage('sprites/zombies/zombieWalk.png')

zomAssets.zombieShootFrame = love.graphics.newImage('sprites/zombies/zombieShoot.png')
zomAssets.zombieShootSprite = love.graphics.newImage('sprites/zombies/zombieShootWalk.png')

zomAssets.bigZombieFrame = love.graphics.newImage('sprites/zombies/zombieBig.png')
zomAssets.bigZombieSprite = love.graphics.newImage('sprites/zombies/zombieBigWalk.png')

zomAssets.smallZombieFrame = love.graphics.newImage('sprites/zombies/zombieSmall.png')
zomAssets.smallZombieSprite = love.graphics.newImage('sprites/zombies/zombieSmallWalk.png')

zomAssets.zombieBullet = love.graphics.newImage('sprites/zombies/bullet.png')
zomAssets.zombieSheet = love.graphics.newImage('sprites/zombies/bullet-sheet.png')
zomAssets.zombieBulletGrid = anim8.newGrid(4, 4, 16, 4)
zomAssets.bulletAnimation = anim8.newAnimation(zomAssets.zombieBulletGrid("1-4",1), 0.15)

zombieTypes.normal = {
  damage        = 15,
  hbScaleX      = 1,
  hbScaleY      = 1,
  hbOffsX       = 6,
  hbOffsY       = -5,
  pScale        = 3,
  friction      = 12,
  rotFactor     = 8,
  rotActiveDist = -1,
  collScale     = .8,
  activeDist    = 120,
  lungeDist     = 40,
  lungeTime     = 1,
  everyLunge    = true,
  canLunge      = true,
  acceleration  = .5, --float between 0 and 1
  goldSpawn     = 8,
  frameTime     = .24,
  frameSize     = 15,
  spriteGap     = 1,
  
  _health = function(diff) return 7 * (1+math.ceil(diff/4)) end,
  _killReward = function() return 5 end,
  _speedMax = function(diff) return 1.3 + math.random(0.0,diff/5) end,
  _speedMin = function() return .4 end,
  
  sprite = zomAssets.zombieSprite,
  frame = zomAssets.zombieFrame,
  width = zomAssets.zombieFrame:getWidth(),
  height = zomAssets.zombieFrame:getHeight()
}

zombieTypes.shooter = {
  damage        = 5,
  bulletV       = 80,
  fireRate      = 3,
  hbScaleX      = 1,
  hbScaleY      = 1,
  hbOffsX       = 6,
  hbOffsY       = -5,
  pScale        = 3,
  friction      = 12,
  rotFactor     = 8,
  rotActiveDist = -1,
  collScale     = .8,
  activeDist    = 80,
  acceleration  = .5, --float between 0 and 1
  goldSpawn     = 8,
  frameTime     = .12,
  frameSize     = 15,
  spriteGap     = 1,
  
  _health = function(diff) return 9 * (1+math.ceil(diff/4)) end,
  _killReward = function(diff) return 5 + math.random(diff, math.ceil(diff*1.7)) end,
  _speedMax = function(diff) return 2.0 + math.random(0.0,diff/5) end,
  _speedMin = function(diff) return .7 + math.random(0.0,diff/5) end,
  
  bulletSprite = zomAssets.zombieBullet,
  bulletSheet = zomAssets.zombieSheet,
  bulletAnimation = zomAssets.bulletAnimation,
  sprite = zomAssets.zombieShootSprite,
  frame = zomAssets.zombieShootFrame,
  width = zomAssets.zombieShootFrame:getWidth(),
  height = zomAssets.zombieShootFrame:getHeight()
}

zombieTypes.big = {
  damage        = 25,
  hbScaleX      = 1.5,
  hbScaleY      = 1.5,
  hbOffsX       = 6,
  hbOffsY       = -5,
  collOffY      = 10,
  pScale        = 5,
  friction      = 14,
  rotFactor     = 32,
  rotActiveDist = 8,
  collScale     = .8,
  activeDist    = 150,
  acceleration  = .8, --float between 0 and 1
  lungeDist     = 70,
  lungeTime     = 1,
  canLunge      = true,
  goldSpawn     = 15,
  frameTime     = .2,
  frameSize     = 30,
  spriteGap     = 2,
  
  _health = function(diff) return 24 * (1+diff/10) end,
  _killReward = function(diff) return 60 + math.random(diff*2, diff*3) end,
  _speedMax = function(diff) return 2.0 + math.random(0,diff/4) end,
  _speedMin = function(diff) return .8 + math.random(0.0,diff/5) end,
  _regen = function(val, diff) return (val + diff*2.33)/1100 end,
  
  sprite = zomAssets.bigZombieSprite,
  frame = zomAssets.bigZombieFrame,
  width = zomAssets.bigZombieFrame:getWidth(),
  height = zomAssets.bigZombieFrame:getHeight()
}


zombieTypes.small = {
  damage        = 10,
  hbScaleX      = 1,
  hbScaleY      = 1,
  hbOffsX       = 6,
  hbOffsY       = -5,
  pScale        = 2,
  friction      = 14,
  rotFactor     = 38,
  rotActiveDist = 8,
  collScale     = .9,
  activeDist    = 100,
  acceleration  = .8, --float between 0 and 1
  lungeDist     = 70,
  lungeTime     = 1,
  goldSpawn     = 5,
  frameTime     = .08,
  frameSize     = 13,
  spriteGap     = 3,
  
  _health = function(diff) return 4 * (1+math.ceil(diff/4)) end,
  _killReward = function(diff) return 30 + math.random(diff*2, diff*3) end,
  _speedMax = function(diff) return 5 + math.random(0,diff/4) end,
  _speedMin = function(diff) return 4 + math.random(0,diff/4) end,
  
  sprite = zomAssets.smallZombieSprite,
  frame = zomAssets.smallZombieFrame,
  width = zomAssets.smallZombieFrame:getWidth(),
  height = zomAssets.smallZombieFrame:getHeight()
}

return zombieTypes