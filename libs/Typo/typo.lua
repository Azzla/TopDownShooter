local typo = {}

function typo.new(text, time, delay, width, align, scale, font, colour)
  local t = {
    t = text,
    time = time,
    delay = delay,
    width = width,
    align = align,
    scale = scale,
    font = font,
    colour = colour,

    string = {},
    index = 1,
    timer = 0,

    text = '',
    isRemoving = false
  }

  local i = 1

  for c in text:gmatch('.') do
    t.string[i] = c

    i = i + 1
  end

  table.insert(typo, t)
  return #typo
end

function typo.update(dt)
  for i,v in ipairs(typo) do
    v.timer = v.timer + dt

    if v.timer >= v.delay and v.index <= #v.string then
      v.text = v.text .. tostring(v.string[v.index])

      v.index = v.index + 1

      v.timer = 0
    elseif v.index >= #v.string and not v.isRemoving then
      v.isRemoving = true
    end
  end
end

function typo.draw(x, y, a)
  for i,v in ipairs(typo) do
    love.graphics.setColor({v.colour[1], v.colour[2], v.colour[3], a})
    love.graphics.setFont(v.font)
    love.graphics.printf(v.text, x, y, v.width, v.align, nil, v.scale, v.scale)
  end
end

function typo.kill(index)
  table.remove(typo, index)
end

return typo 
