local guns = {}
local ParticleManager = require('particleManager')
local ParticlesDict = require('dicts/particlesDict')
--local soundFX = require('sounds')

function player_angle()
  local a,b = cam:cameraCoords(cam:mousePosition())
  local c,d = cam:cameraCoords(player.x, player.y)
  return math.atan2(d - b, c - a) - math.pi/2
end

guns.pistol = {}
guns.pistol.upgrades = {
  dmg = .5,
  reload = .035,
  v = 0,
  clipSize = 1,
  spread = 0
}

guns.pistol.movementPenalty = -50
guns.pistol.sprite = love.graphics.newImage('sprites/pistol.png')
guns.pistol.bulletSprite = love.graphics.newImage('sprites/bullet.png')
guns.pistol.sound = soundFX.pistol
guns.pistol.offsX = -2
guns.pistol.offsY = 9
guns.pistol.bulletOffsX = 4
guns.pistol.bulletOffsY = -7
guns.pistol.dmg = 4
guns.pistol.critChance = 0.00
guns.pistol.v = 350 + guns.pistol.upgrades.v
guns.pistol.knockback = .45 --1 is no effect, negatives increase knockback
guns.pistol.slowdown = 1 --1 is no effect
guns.pistol.currAmmo = 16
guns.pistol.clipSize = 16
guns.pistol.reload = 1.8
guns.pistol.cooldown = 0
guns.pistol.pierce = 0
guns.pistol.spread = function() return (player_angle() - math.pi/math.random(12+guns.pistol.upgrades.spread,18+guns.pistol.upgrades.spread) + math.pi/math.random(12+guns.pistol.upgrades.spread,18+guns.pistol.upgrades.spread)) end
guns.pistol.zoomFactor = 7
guns.pistol.pSpread = ParticlesDict.pistol.fire
guns.pistol.pSys = ParticlesDict.pistol.p:clone()

guns.sniper = {}
guns.sniper.upgrades = {
  dmg = 3,
  pierce = 0,
  reload = 0.05,
  v = 0,
  clipSize = 1
}

guns.sniper.unlocked = true
guns.sniper.movementPenalty = 80
guns.sniper.sprite = love.graphics.newImage('sprites/sniper.png')
guns.sniper.bulletSprite = love.graphics.newImage('sprites/sniperBullet.png')
guns.sniper.sound = soundFX.sniper
guns.sniper.offsX = -2
guns.sniper.offsY = 16
guns.sniper.bulletOffsX = 4
guns.sniper.bulletOffsY = -9
guns.sniper.dmg = 20
guns.sniper.critChance = .03
guns.sniper.v = 750 + guns.sniper.upgrades.v
guns.sniper.knockback = -2
guns.sniper.slowdown = 0.7
guns.sniper.currAmmo = 8
guns.sniper.clipSize = 8
guns.sniper.reload = 3
guns.sniper.cooldown = 1.2
guns.sniper.pierce = 2 + guns.sniper.upgrades.pierce
guns.sniper.pierceFalloff = 7
guns.sniper.spread = player_angle
guns.sniper.zoomFactor = 7
guns.sniper.pSpread = ParticlesDict.sniper.fire
guns.sniper.pSys = ParticlesDict.sniper.p:clone()

guns.shotgun = {}
guns.shotgun.upgrades = {
  dmg = 0,
  reload = 0.1,
  v = 0,
  clipSize = 0,
  spread = 0,
  bullets = 0
}

guns.shotgun.unlocked = true
guns.shotgun.movementPenalty = 0
guns.shotgun.sprite = love.graphics.newImage('sprites/shotgun.png')
guns.shotgun.bulletSprite = love.graphics.newImage('sprites/bullet.png')
guns.shotgun.sound = soundFX.shotgun
guns.shotgun.offsX = -2
guns.shotgun.offsY = 13
guns.shotgun.bulletOffsX = 5
guns.shotgun.bulletOffsY = -8
guns.shotgun.dmg = 7
guns.shotgun.falloff = .024
guns.shotgun.critChance = .01
guns.shotgun.v = 350 + guns.shotgun.upgrades.v
guns.shotgun.knockback = -1
guns.shotgun.slowdown = 0.9
guns.shotgun.currAmmo = 8
guns.shotgun.clipSize = 8
guns.shotgun.bullets = 7
guns.shotgun.reload = 2.7
guns.shotgun.cooldown = .8
guns.shotgun.pierce = 0
guns.shotgun.spread = function() return math.pi/(math.random(10+guns.shotgun.upgrades.spread,16+guns.shotgun.upgrades.spread)) end
guns.shotgun.zoomFactor = 7
guns.shotgun.pSpread = ParticlesDict.shotgun.fire
guns.shotgun.pSys = ParticlesDict.shotgun.p:clone()

guns.autoshotgun = {}
guns.autoshotgun.upgrades = {
  dmg = 0,
  reload = 0,
  v = 0,
  clipSize = 0,
  spread = 0,
  bullets = 0
}

guns.autoshotgun.unlocked = true
guns.autoshotgun.automatic = true
guns.autoshotgun.movementPenalty = 0
guns.autoshotgun.sprite = love.graphics.newImage('sprites/shotgun.png')
guns.autoshotgun.bulletSprite = love.graphics.newImage('sprites/bulletDmg.png')
guns.autoshotgun.sound = soundFX.shotgun
guns.autoshotgun.offsX = -2
guns.autoshotgun.offsY = 13
guns.autoshotgun.bulletOffsX = 5
guns.autoshotgun.bulletOffsY = -8
guns.autoshotgun.dmg = 7
guns.autoshotgun.falloff = .024
guns.autoshotgun.critChance = .01
guns.autoshotgun.v = 350 + guns.autoshotgun.upgrades.v
guns.autoshotgun.knockback = -1
guns.autoshotgun.slowdown = 0.9
guns.autoshotgun.currAmmo = 20
guns.autoshotgun.clipSize = 20
guns.autoshotgun.bullets = 12
guns.autoshotgun.reload = 2.3
guns.autoshotgun.cooldown = .25
guns.autoshotgun.pierce = 0
guns.autoshotgun.spread = function() return math.pi/(math.random(5+guns.autoshotgun.upgrades.spread,10+guns.autoshotgun.upgrades.spread)) end
guns.autoshotgun.zoomFactor = 7
guns.autoshotgun.pSpread = ParticlesDict.shotgun.fire
guns.autoshotgun.pSys = ParticlesDict.shotgun.p:clone()

guns.uzi = {}
guns.uzi.upgrades = {
  dmg = 0,
  reload = 0,
  v = 0,
  clipSize = 0,
  spread = 0,
  bullets = 0,
  cooldown = 1
}

guns.uzi.unlocked = true
guns.uzi.movementPenalty = 0
guns.uzi.automatic = true
guns.uzi.sprite = love.graphics.newImage('sprites/uzi.png')
guns.uzi.bulletSprite = love.graphics.newImage('sprites/bullet.png')
guns.uzi.sound = soundFX.lazer
guns.uzi.sound2 = soundFX.lazer2
guns.uzi.offsX = -4
guns.uzi.offsY = 10
guns.uzi.bulletOffsX = 6
guns.uzi.bulletOffsY = -8
--guns.uzi._dmg = function() return 2 + math.random(10)/10 + guns.uzi.upgrades.dmg end
guns.uzi.dmg = 2
guns.uzi.critChance = .01
guns.uzi.v = 280 + guns.uzi.upgrades.v
guns.uzi.knockback = 1
guns.uzi.slowdown = 1
guns.uzi.currAmmo = 32
guns.uzi.clipSize = 32
guns.uzi.reload = 1.3
guns.uzi.cooldown = .06 / guns.uzi.upgrades.cooldown
guns.uzi.pierce = 0
guns.uzi.spread = function() return (player_angle() - math.pi/math.random(9+guns.uzi.upgrades.spread,18+guns.uzi.upgrades.spread) + math.pi/math.random(9+guns.uzi.upgrades.spread,18+guns.uzi.upgrades.spread)) end
guns.uzi.zoomFactor = 7
guns.uzi.pSpread = ParticlesDict.uzi.fire
guns.uzi.pSys = ParticlesDict.uzi.p:clone()

guns.deagle = {}
guns.deagle.upgrades = {
  dmg = 0,
  reload = 0,
  v = 0,
  clipSize = 0,
  spread = 0,
  bullets = 0
}

guns.deagle.unlocked = true
guns.deagle.movementPenalty = 0
guns.deagle.sprite = love.graphics.newImage('sprites/deagle.png')
guns.deagle.bulletSprite = love.graphics.newImage('sprites/bulletSolid.png')
guns.deagle.sound = soundFX.deagle
guns.deagle.offsX = -3
guns.deagle.offsY = 10
guns.deagle.bulletOffsX = 5
guns.deagle.bulletOffsY = -8
guns.deagle.dmg = 18 + guns.deagle.upgrades.dmg
guns.deagle.critChance = .01
guns.deagle.v = 500 + guns.deagle.upgrades.v
guns.deagle.knockback = -2
guns.deagle.slowdown = 0.8
guns.deagle.currAmmo = 12
guns.deagle.clipSize = 12 + guns.deagle.upgrades.clipSize
guns.deagle.reload = 2
guns.deagle.cooldown = .6
guns.deagle.pierce = 0
guns.deagle.zoomFactor = 7
guns.deagle.spread = player_angle
guns.deagle.pSpread = ParticlesDict.deagle.fire
guns.deagle.pSys = ParticlesDict.deagle.p:clone()

guns.assaultRifle = {}
guns.assaultRifle.upgrades = {
  dmg = 0,
  reload = 0,
  v = 0,
  clipSize = 0,
  spread = 0,
  bullets = 0,
  cooldown = 1
}

guns.assaultRifle.unlocked = true
guns.assaultRifle.automatic = true
guns.assaultRifle.movementPenalty = 0
guns.assaultRifle.sprite = love.graphics.newImage('sprites/assaultRifle.png')
guns.assaultRifle.bulletSprite = love.graphics.newImage('sprites/bulletSolid.png')
guns.assaultRifle.sound = soundFX.assaultLazer
guns.assaultRifle.offsX = -3
guns.assaultRifle.offsY = 15
guns.assaultRifle.bulletOffsX = 5
guns.assaultRifle.bulletOffsY = -12
guns.assaultRifle.dmg = 7 + guns.assaultRifle.upgrades.dmg
guns.assaultRifle.critChance = .03
guns.assaultRifle.v = 400 + guns.assaultRifle.upgrades.v
guns.assaultRifle.knockback = .2
guns.assaultRifle.slowdown = 0.97
guns.assaultRifle.currAmmo = 30
guns.assaultRifle.clipSize = 30 + guns.assaultRifle.upgrades.clipSize
guns.assaultRifle.reload = 2
guns.assaultRifle.cooldown = .13 / guns.assaultRifle.upgrades.cooldown
guns.assaultRifle.spread = function() return (player_angle() - math.pi/math.random(16+guns.assaultRifle.upgrades.spread,21+guns.assaultRifle.upgrades.spread) + math.pi/math.random(16+guns.assaultRifle.upgrades.spread,21+guns.assaultRifle.upgrades.spread)) end
guns.assaultRifle.pierce = 0
guns.assaultRifle.zoomFactor = 7
guns.assaultRifle.pSpread = ParticlesDict.assaultRifle.fire
guns.assaultRifle.pSys = ParticlesDict.assaultRifle.p:clone()

guns.chaingun = {}
guns.chaingun.upgrades = {
  dmg = .5,
  reload = 0.05,
  v = 0,
  clipSize = 20,
  spread = 0,
  bullets = 0,
  cooldown = 1
}

guns.chaingun.unlocked = true
guns.chaingun.automatic = true
guns.chaingun.hasWarmup = true
guns.chaingun.warm = false
guns.chaingun.isWarming = false
guns.chaingun.warmTime = 2.0
guns.chaingun.movementPenalty = 250
guns.chaingun.sprite = love.graphics.newImage('sprites/chaingunFire.png')
guns.chaingun.frame = love.graphics.newImage('sprites/chaingun.png')
guns.chaingun.grid = anim8.newGrid(6, 16, 24, 16)
guns.chaingun.frameTime = { v = 3 }
guns.chaingun.targetTime = { v = 1 }
guns.chaingun.tween = tween.new(2.0, guns.chaingun.frameTime, guns.chaingun.targetTime, "inQuart")
guns.chaingun.animation = anim8.newAnimation(guns.chaingun.grid("1-4",1), 0.05)
guns.chaingun.bulletSprite = love.graphics.newImage('sprites/bulletSolid.png')
guns.chaingun.sound = soundFX.chaingun
guns.chaingun.sound2 = soundFX.chaingun
guns.chaingun.firingSound = soundFX.firingWarm
guns.chaingun.warmSound = soundFX.warmup
guns.chaingun.offsX = -.5
guns.chaingun.offsY = 15
guns.chaingun.bulletOffsX = 4
guns.chaingun.bulletOffsY = -14
guns.chaingun.dmg = 5.5 + guns.chaingun.upgrades.dmg
guns.chaingun.falloff = .027 -- lower is faster falloff
guns.chaingun.critChance = 0.00
guns.chaingun.v = 320 + guns.chaingun.upgrades.v
guns.chaingun.knockback = .5
guns.chaingun.slowdown = 0.97
guns.chaingun.currAmmo = 400
guns.chaingun.clipSize = 400 + guns.chaingun.upgrades.clipSize
guns.chaingun.reload = 6
guns.chaingun.cooldown = .022 / guns.chaingun.upgrades.cooldown
guns.chaingun.pierce = 0
guns.chaingun.spread = function() return (player_angle() - math.pi/math.random(4+guns.chaingun.upgrades.spread,10+guns.chaingun.upgrades.spread) + math.pi/math.random(4+guns.chaingun.upgrades.spread,10+guns.chaingun.upgrades.spread)) end
guns.chaingun.zoomFactor = 7
guns.chaingun.pSpread = ParticlesDict.chaingun.fire
guns.chaingun.pSys = ParticlesDict.chaingun.p:clone()

guns.railgun = {}
guns.railgun.upgrades = {
  dmg = 0,
  reload = 0,
  v = 0,
  clipSize = 0,
  spread = 0,
  bullets = 0,
  cooldown = 1
}

guns.railgun.unlocked = true
guns.railgun.automatic = true
guns.railgun.hasWarmup = true
guns.railgun.warm = false
guns.railgun.isWarming = false
guns.railgun.warmTime = 2.5
guns.railgun.movementPenalty = 0
guns.railgun.sprite = love.graphics.newImage('sprites/guns/railgun.png')
guns.railgun.collision = 4
--guns.railgun.frame = love.graphics.newImage('sprites/chaingun.png')
--guns.railgun.grid = anim8.newGrid(6, 16, 24, 16)
--guns.railgun.frameTime = { v = 3 }
--guns.railgun.targetTime = { v = 1 }
--guns.railgun.tween = tween.new(2.0, guns.chaingun.frameTime, guns.chaingun.targetTime, "inQuart")
--guns.railgun.animation = anim8.newAnimation(guns.chaingun.grid("1-4",1), 0.05)
guns.railgun.bulletSprite = love.graphics.newImage('sprites/guns/railgunShot.png')
guns.railgun.sound = soundFX.railgun_out
guns.railgun.warmSound = soundFX.railgun_in
guns.railgun.offsX = -1
guns.railgun.offsY = 15
guns.railgun.bulletOffsX = 4
guns.railgun.bulletOffsY = -70
guns.railgun.dmg = 88 + guns.railgun.upgrades.dmg
guns.railgun.falloff = 2.027 -- lower is faster falloff
guns.railgun.pierceFalloff = 0
guns.railgun.critChance = 0.00
guns.railgun.v = 2000 + guns.railgun.upgrades.v
guns.railgun.knockback = -8
guns.railgun.slowdown = .7
guns.railgun.currAmmo = 5
guns.railgun.clipSize = 5 + guns.railgun.upgrades.clipSize
guns.railgun.reload = 4
guns.railgun.cooldown = 2.5 / guns.railgun.upgrades.cooldown
guns.railgun.pierce = 100
guns.railgun.spread = player_angle
guns.railgun.zoomFactor = 7
guns.railgun.pSpread = ParticlesDict.railgun.fire
guns.railgun.pSys = ParticlesDict.railgun.p:clone()

return guns