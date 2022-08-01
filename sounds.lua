soundFX = {}
annihilatePlayed = false
soundFXTimer = globalTimer.new()
musicStarted = false

function loadSoundFX()
  soundFX.lazer = love.audio.newSource('sounds/lazer2.mp3', 'static')
  soundFX.reload = love.audio.newSource('sounds/reload.mp3', 'static')
  soundFX.move = love.audio.newSource('sounds/move.mp3', 'static')
  soundFX.makePurchase = love.audio.newSource('sounds/makePurchase.mp3', 'static')
  soundFX.roundStart = love.audio.newSource('sounds/roundStart.mp3', 'static')
  soundFX.dash = love.audio.newSource('sounds/dash.mp3','static')
  soundFX.wind = love.audio.newSource('sounds/wind.mp3', 'stream')
  soundFX.music = love.audio.newSource('sounds/gameMusic2.mp3', 'stream')
  soundFX.musicBoss = love.audio.newSource('sounds/gameMusicBoss.mp3', 'stream')
  soundFX.powerup = love.audio.newSource('sounds/powerup.mp3', 'static')
  soundFX.health = love.audio.newSource('sounds/health.mp3', 'static')
  soundFX.invincible = love.audio.newSource('sounds/invincible.mp3', 'static')
  soundFX.explosion = love.audio.newSource('sounds/explosion.mp3', 'static')
  soundFX.annihilate = love.audio.newSource('sounds/annihiliate.mp3', 'static')
  soundFX.collectCoin = love.audio.newSource('sounds/collectCoin.mp3', 'static')
  
  soundFX.cockPistol = love.audio.newSource('sounds/cockPistol.mp3', 'static')
  soundFX.sniper = love.audio.newSource('sounds/sniper.mp3', 'static')
  soundFX.shotgun = love.audio.newSource('sounds/shotgun.mp3', 'static')
  soundFX.pumpAction = love.audio.newSource('sounds/pumpAction.mp3', 'static')
  soundFX.zoom = love.audio.newSource('sounds/zoom.mp3', 'static')
  
  soundFX.zombies = {}
  soundFX.zombies.death = love.audio.newSource('sounds/zombieDie2.mp3', 'static')
  soundFX.zombies.hit = love.audio.newSource('sounds/zombieHit.mp3', 'static')
  
  soundFX.volumeControl = 3
  
  soundFX.cockPistol:setVolume(.4)
  soundFX.sniper:setVolume(.3)
  soundFX.shotgun:setVolume(.1)
  soundFX.pumpAction:setVolume(.1)
  soundFX.zoom:setVolume(.2)
  
  soundFX.lazer:setVolume(.4)
  soundFX.reload:setVolume(.4)
  soundFX.explosion:setVolume(.12)
  soundFX.move:setVolume(.4)
  soundFX.dash:setVolume(.4)
  soundFX.zombies.death:setVolume(1)
  soundFX.zombies.hit:setVolume(.6)
  soundFX.makePurchase:setVolume(.8)
  soundFX.roundStart:setVolume(.7)
  soundFX.wind:setVolume(0)
  soundFX.music:setVolume(.35)
  soundFX.music:setLooping(true)
  soundFX.musicBoss:setVolume(.35)
  soundFX.musicBoss:setLooping(true)
  soundFX.powerup:setVolume(.5)
  soundFX.health:setVolume(.33)
  soundFX.invincible:setVolume(.3)
  soundFX.annihilate:setVolume(.2)
  soundFX.collectCoin:setVolume(.7)
end

function playMusic()
--  love.audio.play(soundFX.musicBoss)
end

function gameMusic(dt)
  if round.gameState == 2 then
    soundFXTimer:update(dt)
    if not annihilatePlayed then
      love.audio.play(soundFX.annihilate)
      annihilatePlayed = true
    end
    
    if not musicStarted then
      musicStarted = true
      soundFXTimer:after(1.6, function()
        playMusic()
      end)
    end
    
    if soundFX.music:getVolume() ~= .35 then soundFX.music:setVolume(.35) end
    if soundFX.musicBoss:getVolume() ~= .35 then soundFX.musicBoss:setVolume(.35) end
  end
  
  if round.gameState == 3 then
    if soundFX.music:getVolume() ~= .1 then soundFX.music:setVolume(.1) end
    if soundFX.musicBoss:getVolume() ~= .1 then soundFX.musicBoss:setVolume(.1) end
  end
  
  if round.gameState == 5 then
    if soundFX.music:getVolume() ~= 0 then soundFX.music:setVolume(0) end
    if soundFX.musicBoss:getVolume() ~= 0 then soundFX.musicBoss:setVolume(0) end
  end
end