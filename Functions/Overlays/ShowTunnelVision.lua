local isDeathIndicatorVisible = false

lastCalledBlurIntensity = 0
-- 🟢 Function to apply blur with increasing intensity based on health percentage
function ShowTunnelVision(blurIntensity)
  if (blurIntensity == lastCalledBlurIntensity) then return end

  lastCalledBlurIntensity = blurIntensity

  if not UltraHardcore.tunnelVisionFrame then
    local tunnelVisionFrame = CreateFrame('Frame', nil, UIParent)
    tunnelVisionFrame:SetAllPoints(UIParent)
    tunnelVisionFrame:SetFrameStrata('TOOLTIP')
    tunnelVisionFrame:SetFrameLevel(1000)
    tunnelVisionFrame.texture = tunnelVisionFrame:CreateTexture(nil, 'BACKGROUND')
    tunnelVisionFrame.texture:SetAllPoints()
    tunnelVisionFrame.texture:SetColorTexture(0, 0, 0, 0)
    UltraHardcore.tunnelVisionFrame = tunnelVisionFrame
  end

  if not UltraHardcore.backupTunnelVisionFrame then
    local backupTunnelVisionFrame = CreateFrame('Frame', nil, UIParent)
    backupTunnelVisionFrame:SetAllPoints(UIParent)
    backupTunnelVisionFrame:SetFrameStrata('TOOLTIP')
    backupTunnelVisionFrame:SetFrameLevel(1000)
    backupTunnelVisionFrame.texture = backupTunnelVisionFrame:CreateTexture(nil, 'BACKGROUND')
    backupTunnelVisionFrame.texture:SetAllPoints()
    backupTunnelVisionFrame.texture:SetColorTexture(0, 0, 0, 0)
    UltraHardcore.backupTunnelVisionFrame = backupTunnelVisionFrame
  end

  -- Apply the texture to both frames immediately
  local texturePath =
    'Interface\\AddOns\\UltraHardcore\\textures\\tinted_foggy_' .. string.format(
      '%02d',
      blurIntensity
    ) .. '.png'

  if isDeathIndicatorVisible then
    -- Fade out the tunnelVisionFrame and fade in the backupTunnelVisionFrame
    UltraHardcore.backupTunnelVisionFrame.texture:SetTexture(texturePath)
    UltraHardcore.backupTunnelVisionFrame:Show()
    UIFrameFadeIn(UltraHardcore.backupTunnelVisionFrame, 1, 0, 1) -- Fade in backupTunnelVisionFrame
    C_Timer.After(1, function()
      UIFrameFadeOut(UltraHardcore.tunnelVisionFrame, 1, 1, 0) -- Fade out tunnelVisionFrame
    end)
  else
    -- Fade out the backupTunnelVisionFrame and fade in the tunnelVisionFrame
    UltraHardcore.tunnelVisionFrame.texture:SetTexture(texturePath)
    UltraHardcore.tunnelVisionFrame:Show()
    UIFrameFadeIn(UltraHardcore.tunnelVisionFrame, 1, 0, 1) -- Fade in tunnelVisionFrame
    C_Timer.After(1, function()
      UIFrameFadeOut(UltraHardcore.backupTunnelVisionFrame, 1, 1, 0) -- Fade out backupTunnelVisionFrame
    end)
  end

  -- Toggle the visibility flag for the next call
  isDeathIndicatorVisible = not isDeathIndicatorVisible
end
