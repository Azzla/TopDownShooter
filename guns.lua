guns = {}

guns.pistol = {}
guns.pistol.upgrades = {
  dmg = 0,
  reload = 1,
  v = 0,
  clipSize = 0,
  spread = 0
}

guns.pistol.sprite = love.graphics.newImage('sprites/pistol.png')
guns.pistol.bulletSprite = love.graphics.newImage('sprites/bullet.png')
guns.pistol.sound = soundFX.lazer
guns.pistol.sound2 = soundFX.lazer2
guns.pistol.offsX = -2
guns.pistol.offsY = 9
guns.pistol.bulletOffsX = 4
guns.pistol.bulletOffsY = -9
guns.pistol.dmg = 4 + guns.pistol.upgrades.dmg
guns.pistol.v = 250 + guns.pistol.upgrades.v
guns.pistol.currAmmo = 14
guns.pistol.clipSize = 14 + guns.pistol.upgrades.clipSize
guns.pistol.reload = 2 * guns.pistol.upgrades.reload
guns.pistol.cooldown = 0
guns.pistol.pierce = 0
guns.pistol.spread = function() return (player_angle() - math.pi/(14+guns.pistol.upgrades.spread)) + math.pi/math.random(11+guns.pistol.upgrades.spread,17+guns.pistol.upgrades.spread) end
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
guns.sniper.sprite = love.graphics.newImage('sprites/sniper.png')
guns.sniper.bulletSprite = love.graphics.newImage('sprites/sniperBullet.png')
guns.sniper.sound = soundFX.sniper
guns.sniper.offsX = -2
guns.sniper.offsY = 16
guns.sniper.bulletOffsX = 3
guns.sniper.bulletOffsY = -7
guns.sniper.dmg = 33 + guns.sniper.upgrades.dmg
guns.sniper.v = 600 + guns.sniper.upgrades.v
guns.sniper.currAmmo = 6
guns.sniper.clipSize = 6 + guns.sniper.upgrades.clipSize
guns.sniper.reload = 4 * guns.sniper.upgrades.reload
guns.sniper.cooldown = 1.2
guns.sniper.pierce = 2 + guns.sniper.upgrades.pierce
guns.sniper.zoomFactor = 4.5

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
guns.shotgun.sprite = love.graphics.newImage('sprites/shotgun.png')
guns.shotgun.bulletSprite = love.graphics.newImage('sprites/bullet.png')
guns.shotgun.sound = soundFX.shotgun
guns.shotgun.offsX = -2
guns.shotgun.offsY = 13
guns.shotgun.bulletOffsX = 6
guns.shotgun.bulletOffsY = -8
guns.shotgun.dmg = 7 + guns.shotgun.upgrades.dmg
guns.shotgun.v = 350 + guns.shotgun.upgrades.v
guns.shotgun.currAmmo = 8
guns.shotgun.clipSize = 8 + guns.shotgun.upgrades.clipSize
guns.shotgun.bullets = 7 + guns.shotgun.upgrades.bullets
guns.shotgun.reload = 3 * guns.shotgun.upgrades.reload
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
guns.uzi.sprite = love.graphics.newImage('sprites/uzi.png')
guns.uzi.bulletSprite = love.graphics.newImage('sprites/bullet.png')
guns.uzi.sound = soundFX.lazer
guns.uzi.sound2 = soundFX.lazer2
guns.uzi.offsX = -4
guns.uzi.offsY = 10
guns.uzi.bulletOffsX = 6
guns.uzi.bulletOffsY = -8
guns.uzi.dmg = .1 --2.5 + guns.uzi.upgrades.dmg
guns.uzi.v = 300 + guns.uzi.upgrades.v
guns.uzi.currAmmo = 64
guns.uzi.clipSize = 64 + guns.uzi.upgrades.clipSize
guns.uzi.reload = 1.2
guns.uzi.cooldown = .06
guns.uzi.pierce = 0
guns.uzi.spread = function() return (player_angle() - math.pi/(12+guns.uzi.upgrades.spread)) + math.pi/math.random(9+guns.uzi.upgrades.spread,15+guns.uzi.upgrades.spread) end
guns.uzi.zoomFactor = 6

guns.equipped = guns.pistol

gunTimer = globalTimer.new()

table.insert(KEYPRESSED, function(key, scancode)
  if key == '1' then
    if not canReload and guns.equipped == guns.pistol then return end
    if guns.equipped == guns.pistol then return end
    
    switchWeapon('pistol')
    love.audio.play(soundFX.cockPistol)
  elseif key == '2' and guns.sniper.unlocked then
    if not canReload and guns.equipped == guns.sniper then return end
    if guns.equipped == guns.sniper then return end
    
    switchWeapon('sniper')
    love.audio.play(soundFX.zoom)
  elseif key == '3' and guns.shotgun.unlocked then
    if not canReload and guns.equipped == guns.shotgun then return end
    if guns.equipped == guns.shotgun then return end
    
    switchWeapon('shotgun')
    love.audio.play(soundFX.pumpAction)
  elseif key == '4' and guns.uzi.unlocked then
    if not canReload and guns.equipped == guns.uzi then return end
    if guns.equipped == guns.uzi then return end
    
    switchWeapon('uzi')
    love.audio.play(soundFX.cockPistol)
  end
  
  if round.gameState == 2 and canReload and key == 'r' then
    reload()
  end
end)

function processGunSounds()
  love.audio.play(guns.equipped.sound)
  
  if guns.equipped == guns['shotgun'] then
    gunTimer:after(.2, function() love.audio.play(soundFX.pumpAction) end)
  elseif guns.equipped == guns['sniper'] then
    screenShake(.15,.5)
    gunTimer:after(.4, function() love.audio.play(soundFX.pumpAction) end)
  end
end

function switchWeapon(str)
  local prevZoom = guns.equipped.zoomFactor
  
  guns.equipped = guns[str]
  
  switchZoom(prevZoom, guns.equipped.zoomFactor)
  updateTweens()
  
  reloadTimer:clear()
  canShoot = true
  canReload = true
  if guns.equipped.currAmmo == 0 then reload() end
end

function drawGuns()
  love.graphics.draw(guns.equipped.sprite, player.x, player.y, player_angle(), 1, 1, guns.equipped.offsX, guns.equipped.offsY)
end