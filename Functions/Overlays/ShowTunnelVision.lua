local isDeathIndicatorVisible = false

lastCalledBlurIntensity = 0
-- 🟢 Function to apply blur with increasing intensity based on health percentage
function ShowTunnelVision(blurIntensity)
  if (blurIntensity == lastCalledBlurIntensity) then return end

  lastCalledBlurIntensity = blurIntensity

  if not UltraHardcore.tunnelVisionFrame then
    local tunnelVisionFrame = CreateFrame('Frame', nil, UIParent)
    tunnelVisionFrame:SetAllPoints(UIParent)
    tunnelVisionFrame:SetFrameStrata(ChatFrame1:GetFrameStrata())
    tunnelVisionFrame:SetFrameLevel(ChatFrame1:GetFrameLevel() - 1)
    tunnelVisionFrame.texture = tunnelVisionFrame:CreateTexture(nil, 'BACKGROUND')
    tunnelVisionFrame.texture:SetAllPoints()
    tunnelVisionFrame.texture:SetColorTexture(0, 0, 0, 0)
    UltraHardcore.tunnelVisionFrame = tunnelVisionFrame
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
    -- Fade out the tunnelVisionFrame and fade in the backupDeathIndicatorFrame
    UltraHardcore.backupDeathIndicatorFrame.texture:SetTexture(texturePath)
    UltraHardcore.backupDeathIndicatorFrame:Show()
    UIFrameFadeIn(UltraHardcore.backupDeathIndicatorFrame, 1, 0, 1) -- Fade in backupDeathIndicatorFrame
    UIFrameFadeOut(UltraHardcore.tunnelVisionFrame, 1, 1, 0) -- Fade out tunnelVisionFrame
  else
    -- Fade out the backupDeathIndicatorFrame and fade in the tunnelVisionFrame
    UltraHardcore.tunnelVisionFrame.texture:SetTexture(texturePath)
    UltraHardcore.tunnelVisionFrame:Show()
    UIFrameFadeIn(UltraHardcore.tunnelVisionFrame, 1, 0, 1) -- Fade in tunnelVisionFrame
    UIFrameFadeOut(UltraHardcore.backupDeathIndicatorFrame, 1, 1, 0) -- Fade out backupDeathIndicatorFrame
  end

  -- Toggle the visibility flag for the next call
  isDeathIndicatorVisible = not UltraHardcore.isDeathIndicatorVisible
end
