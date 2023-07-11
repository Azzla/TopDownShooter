
shaders = {}
shaders.damaged = false
shaders.nightCycleTime = 1

shaderTimer = globalTimer.new()

function updateShaderTimers(dt)
  shaderTimer:update(dt)
end

function nightCycle()
  local night = true
  shaderTimer:every(.01, function()
    if shaders.nightCycleTime < 128 and night then
      shaders.nightCycleTime = shaders.nightCycleTime + 1
    else
      night = false
    end
    if shaders.nightCycleTime > 1 and not night then
      shaders.nightCycleTime = shaders.nightCycleTime - 1
    else
      night = true
    end
  end)
end

function drawNightShader()
  love.graphics.setShader(nightShader)
  
  nightShader:send("num_lights", 1)
  nightShader:send("lights[0].position", {SCREEN_W / 2, SCREEN_H / 2})
  nightShader:send("lights[0].diffuse", {1.0, 1.0, 1.0})
  nightShader:send("lights[0].power", 25)
  
end

function drawInvincibilityShader()
  invincibilityShader:send("millis", love.timer.getTime())
end

damagedShader = love.graphics.newShader[[
  vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords );
    
    pixel.r = 1;
    pixel.g = 1;
    pixel.b = 1;
    return pixel;
  }
]]

damagedPlayerShader = love.graphics.newShader[[
  vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords );
    
    pixel.g = pixel.g / 2;
    pixel.b = pixel.b / 2;
    return pixel;
  }
]]

invincibilityShader = love.graphics.newShader[[
  
  uniform float millis;
  
  vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords );
    
    pixel.r = pixel.r * sin(millis * 10) * 2;
    pixel.g = pixel.g * cos(millis * 10) * 2;
    pixel.b = pixel.b * tan(millis * 10) * 2;
    
    return pixel;
  }
]]

shopShader = love.graphics.newShader[[
  vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords );
    
    pixel.r = pixel.r / 4;
    pixel.g = pixel.g / 4;
    pixel.b = pixel.b / 4;
    
    return pixel;
  }
]]

pauseShader = love.graphics.newShader[[
  vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords );
    number average = (pixel.r + pixel.g + pixel.b) / 5;
    pixel.r = average;
    pixel.g = average;
    pixel.b = average;
    
    return pixel;
  }
]]

nightShader = love.graphics.newShader[[
  #define NUM_LIGHTS 32
  
  struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
  };
  
  extern Light lights[NUM_LIGHTS];
  extern int num_lights;
  
  const float constant = 1.0;
  const float linear = 0.09;
  const float quadratic = 0.032;
  
  vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    vec2 screen = love_ScreenSize.xy;
    vec2 norm_screen = screen_coords / screen;
    vec3 diffuse = vec3(0);
    
    for (int i = 0; i < num_lights; i++) {
      Light light = lights[i];
      vec2 norm_pos = light.position / screen;
      
      float distance = length(norm_pos - norm_screen) * light.power;
      float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));
      
      diffuse += light.diffuse * attenuation;
    }
    
    diffuse = clamp(diffuse, 0.0, 1.0);
    
    return pixel * vec4(diffuse, 1.0);
  }
]]