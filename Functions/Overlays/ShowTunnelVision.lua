local isTransitioning = false
local currentActiveFrame = nil

lastCalledBlurIntensity = 0
-- 🟢 Function to apply blur with increasing intensity based on health percentage
function ShowTunnelVision(blurIntensity)
  if (blurIntensity == lastCalledBlurIntensity) then return end

  lastCalledBlurIntensity = blurIntensity

  -- Initialize frames if they don't exist
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

  -- Determine which frame is currently active
  local activeFrame = nil
  local inactiveFrame = nil
  
  if UltraHardcore.tunnelVisionFrame:IsShown() and UltraHardcore.tunnelVisionFrame:GetAlpha() > 0 then
    activeFrame = UltraHardcore.tunnelVisionFrame
    inactiveFrame = UltraHardcore.backupTunnelVisionFrame
  elseif UltraHardcore.backupTunnelVisionFrame:IsShown() and UltraHardcore.backupTunnelVisionFrame:GetAlpha() > 0 then
    activeFrame = UltraHardcore.backupTunnelVisionFrame
    inactiveFrame = UltraHardcore.tunnelVisionFrame
  else
    -- No frame is currently active, use tunnelVisionFrame as default
    activeFrame = UltraHardcore.tunnelVisionFrame
    inactiveFrame = UltraHardcore.backupTunnelVisionFrame
  end

  -- Set the texture on the inactive frame first
  local texturePath =
    'Interface\\AddOns\\UltraHardcore\\textures\\tinted_foggy_' .. string.format(
      '%02d',
      blurIntensity
    ) .. '.png'
  
  inactiveFrame.texture:SetTexture(texturePath)
  inactiveFrame:SetAlpha(0)
  inactiveFrame:Show()

  -- Smooth transition: fade out active frame while fading in inactive frame
  local fadeDuration = 0.8 -- Slightly faster transition for smoother feel
  
  -- Stop any existing transitions
  UIFrameFadeOut(activeFrame, 0, activeFrame:GetAlpha(), activeFrame:GetAlpha())
  UIFrameFadeOut(inactiveFrame, 0, inactiveFrame:GetAlpha(), inactiveFrame:GetAlpha())
  
  -- Start the cross-fade transition
  UIFrameFadeOut(activeFrame, fadeDuration, activeFrame:GetAlpha(), 0)
  UIFrameFadeIn(inactiveFrame, fadeDuration, 0, 1)
  
  -- Hide the old frame after transition completes
  C_Timer.After(fadeDuration + 0.1, function()
    if activeFrame:GetAlpha() == 0 then
      activeFrame:Hide()
    end
  end)
end
