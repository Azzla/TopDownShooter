guns = {}

guns.pistol = {}
guns.pistol.sprite = love.graphics.newImage('sprites/pistol.png')
guns.pistol.bulletSprite = love.graphics.newImage('sprites/bullet.png')
guns.pistol.sound = soundFX.lazer
guns.pistol.sound2 = soundFX.lazer2
guns.pistol.offsX = -2
guns.pistol.offsY = 9
guns.pistol.bulletOffsX = -4
guns.pistol.bulletOffsY = 9
guns.pistol.dmg = 3
guns.pistol.v = 250 --250
guns.pistol.currAmmo = 14
guns.pistol.clipSize = 14
guns.pistol.reload = 2
guns.pistol.cooldown = 0
guns.pistol.pierce = 0
guns.pistol.zoomFactor = 6

guns.sniper = {}
guns.sniper.sprite = love.graphics.newImage('sprites/sniper.png')
guns.sniper.bulletSprite = love.graphics.newImage('sprites/sniperBullet.png')
guns.sniper.sound = soundFX.sniper
guns.sniper.offsX = -2
guns.sniper.offsY = 16
guns.sniper.bulletOffsX = -3
guns.sniper.bulletOffsY = 7
guns.sniper.dmg = 22
guns.sniper.v = 600
guns.sniper.currAmmo = 6
guns.sniper.clipSize = 6
guns.sniper.reload = 4
guns.sniper.cooldown = 1.2
guns.sniper.pierce = 2
guns.sniper.zoomFactor = 4.5

guns.shotgun = {}
guns.shotgun.sprite = love.graphics.newImage('sprites/shotgun.png')
guns.shotgun.bulletSprite = love.graphics.newImage('sprites/bullet.png')
guns.shotgun.sound = soundFX.shotgun
guns.shotgun.offsX = -2
guns.shotgun.offsY = 13
guns.shotgun.bulletOffsX = -6
guns.shotgun.bulletOffsY = 8
guns.shotgun.dmg = 10
guns.shotgun.v = 350
guns.shotgun.currAmmo = 8
guns.shotgun.clipSize = 8
guns.shotgun.reload = 3
guns.shotgun.cooldown = .8
guns.shotgun.pierce = 0
guns.shotgun.zoomFactor = 6

guns.equipped = guns.pistol

gunTimer = globalTimer.new()

table.insert(KEYPRESSED, function(key, scancode)
  if key == '1' then
    switchWeapon('pistol')
    love.audio.play(soundFX.cockPistol)
  elseif key == '2' then
    switchWeapon('sniper')
    love.audio.play(soundFX.zoom)
  elseif key == '3' then
    switchWeapon('shotgun')
    love.audio.play(soundFX.pumpAction)
  end
end)

function processGunSounds()
  if guns.equipped.sound:isPlaying() == true then
    if guns.equipped.sound == soundFX.lazer then
      love.audio.play(soundFX.lazer2)
    else
      love.audio.stop(guns.equipped.sound)
      love.audio.play(guns.equipped.sound)
    end
  else
    love.audio.play(guns.equipped.sound)
  end
  
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