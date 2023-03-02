local guns = {}

guns.pistol = {}
guns.pistol.upgrades = {
  dmg = 0,
  reload = 1,
  v = 0,
  clipSize = 0,
  spread = 0
}

guns.pistol.movementPenalty = -50
guns.pistol.sprite = love.graphics.newImage('sprites/pistol.png')
guns.pistol.bulletSprite = love.graphics.newImage('sprites/bullet.png')
guns.pistol.sound = soundFX.lazer
guns.pistol.sound2 = soundFX.lazer2
guns.pistol.offsX = -2
guns.pistol.offsY = 9
guns.pistol.bulletOffsX = 4
guns.pistol.bulletOffsY = -9
guns.pistol.dmg = 4 + guns.pistol.upgrades.dmg
guns.pistol.critChance = .03
guns.pistol.v = 350 + guns.pistol.upgrades.v
guns.pistol.knockback = 0.7
guns.pistol.slowdown = 0.95
guns.pistol.currAmmo = 16
guns.pistol.clipSize = 16 + guns.pistol.upgrades.clipSize
guns.pistol.reload = 1.8 * guns.pistol.upgrades.reload
guns.pistol.cooldown = 0
guns.pistol.pierce = 0
guns.pistol.spread = function() return (player_angle() - math.pi/math.random(12+guns.pistol.upgrades.spread,18+guns.pistol.upgrades.spread) + math.pi/math.random(12+guns.pistol.upgrades.spread,18+guns.pistol.upgrades.spread)) end
guns.pistol.zoomFactor = 6

guns.sniper = {}
guns.sniper.upgrades = {
  dmg = 0,
  pierce = 0,
  reload = 1,
  v = 0,
  clipSize = 0
}

guns.sniper.unlocked = true
guns.sniper.movementPenalty = 80
guns.sniper.sprite = love.graphics.newImage('sprites/sniper.png')
guns.sniper.bulletSprite = love.graphics.newImage('sprites/sniperBullet.png')
guns.sniper.sound = soundFX.sniper
guns.sniper.offsX = -2
guns.sniper.offsY = 16
guns.sniper.bulletOffsX = 3
guns.sniper.bulletOffsY = -7
guns.sniper.dmg = 32 + guns.sniper.upgrades.dmg
guns.sniper.critChance = .03
guns.sniper.v = 650 + guns.sniper.upgrades.v
guns.sniper.knockback = 0.1
guns.sniper.slowdown = 0.4
guns.sniper.currAmmo = 8
guns.sniper.clipSize = 8 + guns.sniper.upgrades.clipSize
guns.sniper.reload = 3 * guns.sniper.upgrades.reload
guns.sniper.cooldown = 1.2
guns.sniper.pierce = 2 + guns.sniper.upgrades.pierce
guns.sniper.zoomFactor = 5

guns.shotgun = {}
guns.shotgun.upgrades = {
  dmg = 0,
  reload = 1,
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
guns.shotgun.bulletOffsX = 6
guns.shotgun.bulletOffsY = -8
guns.shotgun.dmg = 7 + guns.shotgun.upgrades.dmg
guns.shotgun.falloff = .024
guns.shotgun.critChance = .01
guns.shotgun.v = 350 + guns.shotgun.upgrades.v
guns.shotgun.knockback = 0.6
guns.shotgun.slowdown = 0.9
guns.shotgun.currAmmo = 8
guns.shotgun.clipSize = 8 + guns.shotgun.upgrades.clipSize
guns.shotgun.bullets = 7 + guns.shotgun.upgrades.bullets
guns.shotgun.reload = 2.7 * guns.shotgun.upgrades.reload
guns.shotgun.cooldown = .8
guns.shotgun.pierce = 0
guns.shotgun.spread = function() return math.pi/(math.random(10+guns.shotgun.upgrades.spread,16+guns.shotgun.upgrades.spread)) end
guns.shotgun.zoomFactor = 6

guns.uzi = {}
guns.uzi.upgrades = {
  dmg = 0,
  v = 0,
  clipSize = 0,
  spread = 0
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
guns.uzi.dmg = 1.9 + guns.uzi.upgrades.dmg
guns.uzi.critChance = .01
guns.uzi.v = 280 + guns.uzi.upgrades.v
guns.uzi.knockback = 0.90
guns.uzi.slowdown = 0.97
guns.uzi.currAmmo = 32
guns.uzi.clipSize = 32 + guns.uzi.upgrades.clipSize
guns.uzi.reload = 1.3
guns.uzi.cooldown = .06
guns.uzi.pierce = 0
guns.uzi.spread = function() return (player_angle() - math.pi/math.random(9+guns.uzi.upgrades.spread,18+guns.uzi.upgrades.spread) + math.pi/math.random(9+guns.uzi.upgrades.spread,18+guns.uzi.upgrades.spread)) end
guns.uzi.zoomFactor = 6

guns.deagle = {}
guns.deagle.upgrades = {
  dmg = 0,
  v = 0,
  clipSize = 0,
  spread = 0
}

guns.deagle.unlocked = true
guns.deagle.movementPenalty = 0
guns.deagle.sprite = love.graphics.newImage('sprites/deagle.png')
guns.deagle.bulletSprite = love.graphics.newImage('sprites/bulletSolid.png')
guns.deagle.sound = soundFX.deagle
guns.deagle.offsX = -3
guns.deagle.offsY = 10
guns.deagle.bulletOffsX = 6
guns.deagle.bulletOffsY = -8
guns.deagle.dmg = 18 + guns.deagle.upgrades.dmg
guns.deagle.critChance = .01
guns.deagle.v = 500 + guns.deagle.upgrades.v
guns.deagle.knockback = 0.90
guns.deagle.slowdown = 0.97
guns.deagle.currAmmo = 12
guns.deagle.clipSize = 12 + guns.deagle.upgrades.clipSize
guns.deagle.reload = 2
guns.deagle.cooldown = .6
guns.deagle.pierce = 0
guns.deagle.zoomFactor = 6

guns.assaultRifle = {}
guns.assaultRifle.upgrades = {
  dmg = 0,
  v = 0,
  clipSize = 0,
  spread = 0
}

guns.assaultRifle.unlocked = true
guns.assaultRifle.automatic = true
guns.assaultRifle.movementPenalty = 0
guns.assaultRifle.sprite = love.graphics.newImage('sprites/assaultRifle.png')
guns.assaultRifle.bulletSprite = love.graphics.newImage('sprites/bulletSolid.png')
guns.assaultRifle.sound = soundFX.assaultLazer
guns.assaultRifle.offsX = -3
guns.assaultRifle.offsY = 15
guns.assaultRifle.bulletOffsX = 6
guns.assaultRifle.bulletOffsY = -8
guns.assaultRifle.dmg = 8 + guns.assaultRifle.upgrades.dmg
guns.assaultRifle.critChance = .03
guns.assaultRifle.v = 400 + guns.assaultRifle.upgrades.v
guns.assaultRifle.knockback = 0.90
guns.assaultRifle.slowdown = 0.97
guns.assaultRifle.currAmmo = 30
guns.assaultRifle.clipSize = 30 + guns.assaultRifle.upgrades.clipSize
guns.assaultRifle.reload = 2
guns.assaultRifle.cooldown = .15
guns.assaultRifle.spread = function() return (player_angle() - math.pi/math.random(16+guns.assaultRifle.upgrades.spread,21+guns.assaultRifle.upgrades.spread) + math.pi/math.random(16+guns.assaultRifle.upgrades.spread,21+guns.assaultRifle.upgrades.spread)) end
guns.assaultRifle.pierce = 0
guns.assaultRifle.zoomFactor = 6

guns.chaingun = {}
guns.chaingun.upgrades = {
  dmg = 0,
  v = 0,
  clipSize = 0,
  spread = 0
}

guns.chaingun.unlocked = true
guns.chaingun.automatic = true
guns.chaingun.hasWarmup = true
guns.chaingun.warm = false
guns.chaingun.isWarming = false
guns.chaingun.warmTime = 2.0
guns.chaingun.movementPenalty = 250
guns.chaingun.sprite = love.graphics.newImage('sprites/chaingun.png')
guns.chaingun.bulletSprite = love.graphics.newImage('sprites/bulletSolid.png')
guns.chaingun.sound = soundFX.chaingun
guns.chaingun.sound2 = soundFX.chaingun
guns.chaingun.firingSound = soundFX.firingWarm
guns.chaingun.offsX = -1
guns.chaingun.offsY = 15
guns.chaingun.bulletOffsX = 6
guns.chaingun.bulletOffsY = -8
guns.chaingun.dmg = 5.5 + guns.chaingun.upgrades.dmg
guns.chaingun.falloff = .030 -- lower is faster falloff
guns.chaingun.critChance = 0.00
guns.chaingun.v = 350 + guns.chaingun.upgrades.v
guns.chaingun.knockback = 0.90
guns.chaingun.slowdown = 0.97
guns.chaingun.currAmmo = 400
guns.chaingun.clipSize = 400 + guns.chaingun.upgrades.clipSize
guns.chaingun.reload = 6
guns.chaingun.cooldown = .022
guns.chaingun.pierce = 0
guns.chaingun.spread = function() return (player_angle() - math.pi/math.random(6+guns.chaingun.upgrades.spread,20+guns.chaingun.upgrades.spread) + math.pi/math.random(6+guns.chaingun.upgrades.spread,20+guns.chaingun.upgrades.spread)) end
guns.chaingun.zoomFactor = 6

return guns