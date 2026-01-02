-- Smooth fade in for textures
function SmoothTextureFadeIn(texture, duration)
  if not texture or type(texture) ~= 'table' then
    print('UltraHardcore: Invalid texture provided to SmoothTextureFadeIn')
    return
  end

  if not texture.isFilled then
    UIFrameFadeIn(texture, duration or 0.2, 0, 1)
    texture.isFilled = true
  end
end
