local gunsRef = require('dicts/gunsDict')
guns = require('dicts/gunsDict')

guns.equipped = guns.pistol


gunTimer = globalTimer.new()

function calcBonuses(skills)
  for gun in pairs(guns) do
    if gun ~= 'equipped' then
      local _g = guns[gun]
      local g_ref = gunsRef[gun]
      
      _g.clipSize = g_ref.clipSize + math.floor(skills.maxAmmo * _g.upgrades.clipSize)
      _g.currAmmo = _g.clipSize
      
      _g.dmg = g_ref.dmg + math.floor(skills.damage * _g.upgrades.dmg)
      _g.reload = g_ref.reload - (skills.reload * _g.upgrades.reload)
      if _g.reload <= .1 then _g.reload = .1 end
      updateTweens()
    end
  end
end

function processGunSounds()
  love.audio.play(guns.equipped.sound)
  
  if guns.equipped == guns['shotgun'] then
    gunTimer:after(.2, function() love.audio.play(soundFX.pumpAction) end)
  elseif guns.equipped == guns['sniper'] then
    screenShake(.15,.5)
    gunTimer:after(.4, function() love.audio.play(soundFX.pumpAction) end)
  elseif guns.equipped == guns['railgun'] then
    screenShake(.25,.6)
  end
end

function gunKeybinds(key)
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
  elseif key == '8' and guns.railgun.unlocked then
    if not canReload and guns.equipped == guns.railgun then return end
    if guns.equipped == guns.railgun then return end
    
    switchWeapon('railgun')
    love.audio.play(soundFX.zoom)
  elseif key == '9' and guns.autoshotgun.unlocked then
    if not canReload and guns.equipped == guns.autoshotgun then return end
    if guns.equipped == guns.autoshotgun then return end
    
    switchWeapon('autoshotgun')
    love.audio.play(soundFX.pumpAction)
  end
  
  if canReload and key == 'r' then
    reload()
  end
end

function switchWeapon(str)
  if guns.equipped.hasWarmup then
    guns.equipped.warm = false
    guns.equipped.isWarming = false
    warmingTimer:clear()
    love.audio.stop(guns.equipped.warmSound)
    love.audio.stop(soundFX.firingWarm)
  end
  
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
  if guns.equipped.animation then
    guns.equipped.animation:draw(guns.equipped.sprite, player.x, player.y, player_angle(), 1, 1, guns.equipped.offsX, guns.equipped.offsY)
  else
    love.graphics.draw(guns.equipped.sprite, player.x, player.y, player_angle(), 1, 1, guns.equipped.offsX, guns.equipped.offsY)
  end
end