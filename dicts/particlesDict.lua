local Particles = {}

--Pistol
Particles.pistol = {}
Particles.pistol.p = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
Particles.pistol.p:setParticleLifetime (.05, .08)
Particles.pistol.p:setSizes(1)
Particles.pistol.p:setSpeed(90)
Particles.pistol.p:setColors(1, 1, 1, 1, rgb(183), rgb(231), rgb(246), 1)
Particles.pistol.fire = function(pAngle)
  return { math.random(4,8), pAngle - math.pi/2 - math.pi/8, math.pi/4, 1 }
end

--Sniper
Particles.sniper = {}
Particles.sniper.p = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
Particles.sniper.p:setParticleLifetime (.08, .18)
Particles.sniper.p:setSizes(1,.8)
Particles.sniper.p:setSpeed(150)
Particles.sniper.p:setColors(1, 1, 1, 1, rgb(183), rgb(231), rgb(246), 1)
Particles.sniper.fire = function(pAngle)
  return { math.random(5,10), pAngle - math.pi/2 - math.pi/12, math.pi/6, 1 }
end

--Shotgun
Particles.shotgun = {}
Particles.shotgun.p = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
Particles.shotgun.p:setParticleLifetime (.12, .18)
Particles.shotgun.p:setSizes(1,2,3)
Particles.shotgun.p:setSpeed(50)
Particles.shotgun.p:setColors(1, 1, 1, 1, rgb(183), rgb(231), rgb(246), 1)
Particles.shotgun.fire = function(pAngle)
  return { math.random(10,15), pAngle - math.pi/2 - math.pi/8, math.pi/4, 1 }
end

--Uzi
Particles.uzi = {}
Particles.uzi.p = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
Particles.uzi.p:setParticleLifetime (.05, .1)
Particles.uzi.p:setSizes(1)
Particles.uzi.p:setSpeed(120)
Particles.uzi.p:setColors(1, 1, 1, 1, rgb(183), rgb(231), rgb(246), 1)
Particles.uzi.fire = function(pAngle)
  return { math.random(6,12), pAngle - math.pi/2 - math.pi/8, math.pi/4, 1 }
end

--Deagle
Particles.deagle = {}
Particles.deagle.p = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
Particles.deagle.p:setParticleLifetime (.05, .08)
Particles.deagle.p:setSizes(1,.5)
Particles.deagle.p:setSpeed(200)
Particles.deagle.p:setColors(1, 1, 1, 1, rgb(255), rgb(255), rgb(255), 1)
Particles.deagle.fire = function(pAngle)
  return { math.random(3,7), pAngle - math.pi/2 - math.pi/8, math.pi/4, 1 }
end

--AssaultRifle
Particles.assaultRifle = {}
Particles.assaultRifle.p = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
Particles.assaultRifle.p:setParticleLifetime (.05, .12)
Particles.assaultRifle.p:setSizes(1.5,1)
Particles.assaultRifle.p:setSpeed(80)
Particles.assaultRifle.p:setColors(1, 1, 1, 1, rgb(255), rgb(255), rgb(255), 1)
Particles.assaultRifle.fire = function(pAngle)
  return { math.random(6,12), pAngle - math.pi/2 - math.pi/8, math.pi/4, 1 }
end

--Chaingun
Particles.chaingun = {}
Particles.chaingun.p = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
Particles.chaingun.p:setParticleLifetime (.05, .12)
Particles.chaingun.p:setSizes(1,2)
Particles.chaingun.p:setSpeed(40)
Particles.chaingun.p:setColors(1, 1, 1, 1, rgb(255), rgb(255), rgb(255), 1)
Particles.chaingun.fire = function(pAngle)
  return { math.random(2,6), pAngle - math.pi/2 - math.pi/4, math.pi/2, 1 }
end

--Railgun
Particles.railgun = {}
Particles.railgun.p = love.graphics.newParticleSystem(love.graphics.newImage('sprites/pfx/particle2.png'), 100)
Particles.railgun.p:setParticleLifetime (.08, .18)
Particles.railgun.p:setSizes(1,.8)
Particles.railgun.p:setSpeed(150)
Particles.railgun.p:setColors(1, 1, 1, 1, rgb(183), rgb(231), rgb(246), 1)
Particles.railgun.fire = function(pAngle)
  return { math.random(5,10), pAngle - math.pi/2 - math.pi/12, math.pi/6, 1 }
end

return Particles