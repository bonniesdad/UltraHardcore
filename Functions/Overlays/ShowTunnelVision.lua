-- Initialize the tunnel vision frames table if it doesn't exist
if not UltraHardcore.tunnelVisionFrames then
  UltraHardcore.tunnelVisionFrames = {}
end

-- 🟢 Function to apply blur with increasing intensity based on health percentage
-- Now supports stacking multiple overlays
function ShowTunnelVision(blurIntensity)
  -- Create a unique frame name based on blur intensity
  local frameName = 'UltraHardcoreTunnelVision_' .. blurIntensity
  
  -- Check if frame already exists and is visible
  if UltraHardcore.tunnelVisionFrames[frameName] and UltraHardcore.tunnelVisionFrames[frameName]:IsShown() then
    return -- Frame already exists and is visible
  end
  
  -- Create the frame if it doesn't exist
  if not UltraHardcore.tunnelVisionFrames[frameName] then
    local tunnelVisionFrame = CreateFrame('Frame', frameName, UIParent)
    tunnelVisionFrame:SetAllPoints(UIParent)
    
    -- Set frame strata and level based on tunnelVisionMaxStrata setting
    if GLOBAL_SETTINGS.tunnelVisionMaxStrata then
      tunnelVisionFrame:SetFrameStrata('FULLSCREEN_DIALOG')
      tunnelVisionFrame:SetFrameLevel(1000 + blurIntensity) -- Stack frames with different levels
    else
      tunnelVisionFrame:SetFrameStrata(ChatFrame1:GetFrameStrata())
      tunnelVisionFrame:SetFrameLevel(ChatFrame1:GetFrameLevel() - 1 + blurIntensity) -- Stack frames with different levels
    end
    
    tunnelVisionFrame.texture = tunnelVisionFrame:CreateTexture(nil, 'BACKGROUND')
    tunnelVisionFrame.texture:SetAllPoints()
    tunnelVisionFrame.texture:SetColorTexture(0, 0, 0, 0)
    
    -- Store the frame reference
    UltraHardcore.tunnelVisionFrames[frameName] = tunnelVisionFrame
  end
  
  local frame = UltraHardcore.tunnelVisionFrames[frameName]
  
  -- Set the texture
  local texturePath =
    'Interface\\AddOns\\UltraHardcore\\textures\\tinted_foggy_' .. string.format(
      '%02d',
      blurIntensity
    ) .. '.png'
  
  frame.texture:SetTexture(texturePath)
  frame:SetAlpha(0)
  frame:Show()

  -- Smooth fade in
  local fadeDuration = 0.5 -- Fade in duration for new overlays
  UIFrameFadeIn(frame, fadeDuration, 0, 1)
end
