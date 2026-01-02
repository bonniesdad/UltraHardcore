-- Create a combo point orb
function CreateComboPointOrb(parent, index, totalPoints, texturePath, shadowTexturePath)
  if not parent or type(parent) ~= 'table' then
    print('UltraHardcore: Invalid parent frame provided to CreateComboPointOrb')
    return nil
  end

  if not index or not totalPoints or type(index) ~= 'number' or type(totalPoints) ~= 'number' then
    print('UltraHardcore: Invalid index or totalPoints provided to CreateComboPointOrb')
    return nil
  end

  if not texturePath or not shadowTexturePath or type(texturePath) ~= 'string' or type(
    shadowTexturePath
  ) ~= 'string' then
    print('UltraHardcore: Invalid texture paths provided to CreateComboPointOrb')
    return nil
  end

  local container = CreateFrame('Frame', nil, parent)
  if not container then
    print('UltraHardcore: Failed to create combo point container')
    return nil
  end

  container:SetSize(32, 32)
  container:SetPoint('CENTER', parent, 'CENTER', (index - (totalPoints + 1) / 2) * 40, 0)

  -- Outline (always visible)
  local outline = container:CreateTexture(nil, 'BACKGROUND')
  if not outline then
    print('UltraHardcore: Failed to create outline texture')
    return nil
  end

  outline:SetTexture(shadowTexturePath)
  outline:SetVertexColor(0.3, 0.3, 0.3)
  outline:SetAllPoints(container)

  -- Fill (only visible when active)
  local fill = container:CreateTexture(nil, 'ARTWORK')
  if not fill then
    print('UltraHardcore: Failed to create fill texture')
    return nil
  end

  fill:SetTexture(texturePath)
  fill:SetAllPoints(container)
  fill:Hide()

  return {
    container = container,
    fill = fill,
    outline = outline,
    isFilled = false,
  }
end
