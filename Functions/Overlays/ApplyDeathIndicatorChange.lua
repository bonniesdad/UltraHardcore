local isDeathIndicatorVisible = false

lastCalledBlurIntensity = 0
-- 🟢 Function to apply blur with increasing intensity based on health percentage
function ApplyDeathIndicatorChange(blurIntensity)
  if (blurIntensity == lastCalledBlurIntensity) then return end

  lastCalledBlurIntensity = blurIntensity

  if not UltraHardcore.deathIndicatorFrame then
    local deathIndicatorFrame = CreateFrame('Frame', nil, UIParent)
    deathIndicatorFrame:SetAllPoints(UIParent)
    deathIndicatorFrame:SetFrameStrata(ChatFrame1:GetFrameStrata())
    deathIndicatorFrame:SetFrameLevel(ChatFrame1:GetFrameLevel() - 1)
    deathIndicatorFrame.texture = deathIndicatorFrame:CreateTexture(nil, 'BACKGROUND')
    deathIndicatorFrame.texture:SetAllPoints()
    deathIndicatorFrame.texture:SetColorTexture(0, 0, 0, 0)
    UltraHardcore.deathIndicatorFrame = deathIndicatorFrame
  end

  if not UltraHardcore.backupDeathIndicatorFrame then
    local backupDeathIndicatorFrame = CreateFrame('Frame', nil, UIParent)
    backupDeathIndicatorFrame:SetAllPoints(UIParent)
    backupDeathIndicatorFrame:SetFrameStrata(ChatFrame1:GetFrameStrata())
    backupDeathIndicatorFrame:SetFrameLevel(ChatFrame1:GetFrameLevel() - 1)
    backupDeathIndicatorFrame.texture = backupDeathIndicatorFrame:CreateTexture(nil, 'BACKGROUND')
    backupDeathIndicatorFrame.texture:SetAllPoints()
    backupDeathIndicatorFrame.texture:SetColorTexture(0, 0, 0, 0)
    UltraHardcore.backupDeathIndicatorFrame = backupDeathIndicatorFrame
  end

  -- Apply the texture to both frames immediately
  local texturePath =
    'Interface\\AddOns\\UltraHardcore\\textures\\tinted_foggy_' .. string.format(
      '%02d',
      blurIntensity
    ) .. '.png'

  if isDeathIndicatorVisible then
    -- Fade out the deathIndicatorFrame and fade in the backupDeathIndicatorFrame
    UltraHardcore.backupDeathIndicatorFrame.texture:SetTexture(texturePath)
    UltraHardcore.backupDeathIndicatorFrame:Show()
    UIFrameFadeIn(UltraHardcore.backupDeathIndicatorFrame, 1, 0, 1) -- Fade in backupDeathIndicatorFrame
    UIFrameFadeOut(UltraHardcore.deathIndicatorFrame, 1, 1, 0) -- Fade out deathIndicatorFrame
  else
    -- Fade out the backupDeathIndicatorFrame and fade in the deathIndicatorFrame
    UltraHardcore.deathIndicatorFrame.texture:SetTexture(texturePath)
    UltraHardcore.deathIndicatorFrame:Show()
    UIFrameFadeIn(UltraHardcore.deathIndicatorFrame, 1, 0, 1) -- Fade in deathIndicatorFrame
    UIFrameFadeOut(UltraHardcore.backupDeathIndicatorFrame, 1, 1, 0) -- Fade out backupDeathIndicatorFrame
  end

  -- Toggle the visibility flag for the next call
  isDeathIndicatorVisible = not UltraHardcore.isDeathIndicatorVisible
end
