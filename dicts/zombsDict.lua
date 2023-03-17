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
  activeDist    = -1,
  goldSpawn     = 8,
  frameTime     = .12,
  frameSize     = 15,
  spriteGap     = 1,
  
  _health = function() return 9 * (1+math.ceil(round.difficulty/4)) end,
  _killReward = function() return 5 + math.random(round.difficulty, math.ceil(round.difficulty*1.7)) end,
  _speedMax = function() return 3.0 + math.random(0.0,round.difficulty/5) end,
  _speedMin = function() return 2.2 + math.random(0.0,round.difficulty/5) end,
  _spawn = function() return math.random(280,400) end,
  
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
  goldSpawn     = 8,
  frameTime     = .12,
  frameSize     = 15,
  spriteGap     = 1,
  
  _health = function() return 9 * (1+math.ceil(round.difficulty/4)) end,
  _killReward = function() return 5 + math.random(round.difficulty, math.ceil(round.difficulty*1.7)) end,
  _speedMax = function() return 2.0 + math.random(0.0,round.difficulty/5) end,
  _speedMin = function() return 1.2 + math.random(0.0,round.difficulty/5) end,
  _spawn = function() return math.random(280,400) end,
  
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
  pScale        = 5,
  friction      = 14,
  rotFactor     = 32,
  rotActiveDist = 8,
  collScale     = .8,
  activeDist    = 120,
  goldSpawn     = 15,
  frameTime     = .2,
  frameSize     = 30,
  spriteGap     = 2,
  
  _health = function() return 29 * (1+math.ceil(round.difficulty/4)) end,
  _killReward = function() return 60 + math.random(round.difficulty*2, round.difficulty*3) end,
  _speedMax = function() return 4.5 + math.random(0,round.difficulty/4) end,
  _speedMin = function() return 2.5 + math.random(0.0,round.difficulty/5) end,
  _spawn = function() return math.random(350,400) end,
  _regen = function(val) return (val + round.difficulty*2.33)/1250 end,
  
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
  goldSpawn     = 5,
  frameTime     = .08,
  frameSize     = 13,
  spriteGap     = 3,
  
  _health = function() return 4 * (1+math.ceil(round.difficulty/4)) end,
  _killReward = function() return 30 + math.random(round.difficulty*2, round.difficulty*3) end,
  _speedMax = function() return 9 + math.random(0,round.difficulty/4) end,
  _speedMin = function() return 6 + math.random(0,round.difficulty/4) end,
  _spawn = function() return math.random(270,350) end,
  
  sprite = zomAssets.smallZombieSprite,
  frame = zomAssets.smallZombieFrame,
  width = zomAssets.smallZombieFrame:getWidth(),
  height = zomAssets.smallZombieFrame:getHeight()
}

return zombieTypes