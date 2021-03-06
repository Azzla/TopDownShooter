soundFX = {}

function loadSoundFX()
  soundFX.lazer = love.audio.newSource('sounds/lazer2.mp3', 'static')
  soundFX.lazer2 = love.audio.newSource('sounds/lazer2.mp3', 'static')
  soundFX.move = love.audio.newSource('sounds/move.mp3', 'static')
  soundFX.makePurchase = love.audio.newSource('sounds/makePurchase.mp3', 'static')
  soundFX.roundStart = love.audio.newSource('sounds/roundStart.mp3', 'static')
  soundFX.dash = love.audio.newSource('sounds/dash.mp3','static')
  soundFX.wind = love.audio.newSource('sounds/wind.mp3', 'stream')
  soundFX.music = love.audio.newSource('sounds/gameMusic2.mp3', 'stream')
  
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
  
  soundFX.lazer:setVolume(.3)
  soundFX.lazer2:setVolume(.2)
  soundFX.move:setVolume(.4)
  soundFX.dash:setVolume(.4)
  soundFX.zombies.death:setVolume(.6)
  soundFX.zombies.hit:setVolume(.4)
  soundFX.makePurchase:setVolume(.8)
  soundFX.roundStart:setVolume(.7)
  soundFX.wind:setVolume(0)
  soundFX.music:setVolume(.3)
  
  soundFX.collectCoin.m1:setVolume(1)
  soundFX.collectCoin.m2:setVolume(.2)
  soundFX.collectCoin.m3:setVolume(.3)
  soundFX.collectCoin.m4:setVolume(.4)
  soundFX.collectCoin.m5:setVolume(.5)
end

function gameMusic(dt)
  if round.gameState == 2 then
    if soundFX.music:isPlaying() == false then
      love.audio.play(soundFX.music)
    end
  end
  if round.gameState == 3 and soundFX.music:getVolume() ~= .04 then
    soundFX.music:setVolume(.04)
  end
end