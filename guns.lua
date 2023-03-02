guns = require('dicts/gunsDict')

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
  elseif key == '5' and guns.deagle.unlocked then
    if not canReload and guns.equipped == guns.deagle then return end
    if guns.equipped == guns.deagle then return end
    
    switchWeapon('deagle')
    love.audio.play(soundFX.cockPistol)
  elseif key == '6' and guns.chaingun.unlocked then
    if not canReload and guns.equipped == guns.chaingun then return end
    if guns.equipped == guns.chaingun then return end
    
    switchWeapon('chaingun')
    love.audio.play(soundFX.cockPistol)
  elseif key == '7' and guns.assaultRifle.unlocked then
    if not canReload and guns.equipped == guns.assaultRifle then return end
    if guns.equipped == guns.assaultRifle then return end
    
    switchWeapon('assaultRifle')
    love.audio.play(soundFX.zoom)
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