soundFX = {}
annihilatePlayed = false
soundFXTimer = globalTimer.new()
musicStarted = false

function loadSoundFX()
  soundFX.lazer = love.audio.newSource('sounds/lazer2.mp3', 'static')
  soundFX.lazer2 = love.audio.newSource('sounds/lazer2.mp3', 'static')
  soundFX.lazer3 = love.audio.newSource('sounds/lazer2.mp3', 'static')
  soundFX.lazer4 = love.audio.newSource('sounds/lazer2.mp3', 'static')
  soundFX.lazer5 = love.audio.newSource('sounds/lazer2.mp3', 'static')
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
  
  soundFX.cockPistol = love.audio.newSource('sounds/cockPistol.mp3', 'static')
  soundFX.sniper = love.audio.newSource('sounds/sniper.mp3', 'static')
  soundFX.shotgun = love.audio.newSource('sounds/shotgun.mp3', 'static')
  soundFX.pumpAction = love.audio.newSource('sounds/pumpAction.mp3', 'static')
  soundFX.zoom = love.audio.newSource('sounds/zoom.mp3', 'static')
  
  soundFX.collectCoin = {}
  soundFX.collectCoin.m1 = love.audio.newSource('sounds/collectCoin.mp3', 'static')
  soundFX.collectCoin.m2 = love.audio.newSource('sounds/collectCoin.mp3', 'static')
  soundFX.collectCoin.m3 = love.audio.newSource('sounds/collectCoin.mp3', 'static')
  soundFX.collectCoin.m4 = love.audio.newSource('sounds/collectCoin.mp3', 'static')
  soundFX.collectCoin.m5 = love.audio.newSource('sounds/collectCoin.mp3', 'static')
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
  soundFX.lazer2:setVolume(.3)
  soundFX.lazer3:setVolume(.2)
  soundFX.lazer4:setVolume(.1)
  soundFX.lazer5:setVolume(.1)
  soundFX.reload:setVolume(.3)
  soundFX.explosion:setVolume(.12)
  soundFX.move:setVolume(.4)
  soundFX.dash:setVolume(.4)
  soundFX.zombies.death:setVolume(.6)
  soundFX.zombies.hit:setVolume(.4)
  soundFX.makePurchase:setVolume(.8)
  soundFX.roundStart:setVolume(.7)
  soundFX.wind:setVolume(0)
  soundFX.music:setVolume(.35)
  soundFX.musicBoss:setVolume(.35)
  soundFX.powerup:setVolume(.5)
  soundFX.health:setVolume(.33)
  soundFX.invincible:setVolume(.3)
  soundFX.annihilate:setVolume(.2)
  
  soundFX.collectCoin.m1:setVolume(1)
  soundFX.collectCoin.m2:setVolume(.3)
  soundFX.collectCoin.m3:setVolume(.5)
  soundFX.collectCoin.m4:setVolume(.7)
  soundFX.collectCoin.m5:setVolume(1)
end

function playMusic()
  if soundFX.music:isPlaying() then
    love.audio.pause(soundFX.music)
    love.audio.play(soundFX.music)
  else
    love.audio.play(soundFX.music)
  end
end

function gameMusic(dt)
  if round.gameState == 2 then
    soundFXTimer:update(dt)
    if not annihilatePlayed then
      love.audio.play(soundFX.annihilate)
      annihilatePlayed = true
    end
    if round.difficulty ~= 0 and round.difficulty % 5 >= 0 then
      if not musicStarted then
        soundFXTimer:after(1.6, function()
          playMusic()
          musicStarted = true
        end)
      else
        playMusic()
      end
    else
      if soundFX.music:isPlaying() == false then
        love.audio.pause(soundFX.musicBoss)
        love.audio.play(soundFX.music)
      end
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

function calculateLazerAudio()
  if soundFX.lazer:isPlaying() == true then
    if soundFX.lazer2:isPlaying() == true then
      love.audio.play(soundFX.lazer5)
      
      if soundFX.lazer3:isPlaying() == true then
        
        love.audio.play(soundFX.lazer5)
        
        if soundFX.lazer4:isPlaying() == true then
          
          love.audio.play(soundFX.lazer5)
        else
          love.audio.play(soundFX.lazer4)
        end
      else
        love.audio.play(soundFX.lazer3)
      end
    else
      love.audio.play(soundFX.lazer2)
    end
  else
    love.audio.play(soundFX.lazer)
  end
end

function calculateCoinAudio()
  if soundFX.collectCoin.m1:isPlaying() == true then
    if soundFX.collectCoin.m2:isPlaying() == true then
      love.audio.play(soundFX.collectCoin.m5)
      if soundFX.collectCoin.m3:isPlaying() == true then
        love.audio.play(soundFX.collectCoin.m5)
        if soundFX.collectCoin.m4:isPlaying() == true then
          love.audio.play(soundFX.collectCoin.m5)
        else
          love.audio.play(soundFX.collectCoin.m4)
        end
      else
        love.audio.play(soundFX.collectCoin.m3)
      end
    else
      love.audio.play(soundFX.collectCoin.m2)
    end
  else
    love.audio.play(soundFX.collectCoin.m1)
  end
end