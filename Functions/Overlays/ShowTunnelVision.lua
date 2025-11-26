-- Initialize the tunnel vision frames table if it doesn't exist
if not UltraHardcore.tunnelVisionFrames then
  UltraHardcore.tunnelVisionFrames = {}
end

-- Table defining seasonal themes with date ranges and texture prefixes
-- local seasonalThemes = {
--   {
--     name = "Halloween",
--     startMonth = 10,
--     startDay = 17,
--     endMonth = 11,
--     endDay = 1,
--     texturePrefix = "halloween_foggy_",
--   },
  -- Add more themes here, e.g.:
  -- {
  --   name = "Winter",
  --   startMonth = 12,
  --   startDay = 20,
  --   endMonth = 1,
  --   endDay = 5,
  --   texturePrefix = "winter_foggy_",
  -- },
-- }

-- local function GetActiveSeasonalTheme()
--   local currentDate = date("*t") -- Get current date as a table
--   local month = currentDate.month
--   local day = currentDate.day

--   for _, theme in ipairs(seasonalThemes) do
--     local isActive = (
--       (month == theme.startMonth and day >= theme.startDay) or
--       (month == theme.endMonth and day <= theme.endDay) or
--       (theme.startMonth > theme.endMonth and month > theme.startMonth) or
--       (theme.startMonth > theme.endMonth and month < theme.endMonth)
--     )
--     if isActive then
--       return theme.texturePrefix
--     end
--   end
--   return nil -- No seasonal theme active
-- end

-- 🟢 Function to apply blur with increasing intensity based on health percentage
-- Now supports stacking multiple overlays
function ShowTunnelVision(blurIntensity)
  -- Create a unique frame name based on blur intensity
  local frameName = 'UltraHardcoreTunnelVision_' .. blurIntensity
  
  -- Check if frame already exists and is visible
  if UltraHardcore.tunnelVisionFrames[frameName] and UltraHardcore.tunnelVisionFrames[frameName]:IsShown() then
    local existingFrame = UltraHardcore.tunnelVisionFrames[frameName]
    local currentAlpha = existingFrame:GetAlpha() or 0
    -- If it's mid-fade-out (shown but alpha < 1), cancel fade-out and fade back in immediately
    if currentAlpha < 1 then
      if UIFrameFadeRemoveFrame then
        UIFrameFadeRemoveFrame(existingFrame)
      end
      UIFrameFadeIn(existingFrame, 0.2, currentAlpha, 1)
    end
    return -- Already shown; either ensured fully visible or already at full alpha
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
  
  -- Determine the texture based on active seasonal theme
  local texturePrefix = GLOBAL_SETTINGS.spookyTunnelVision and "halloween_foggy_" or "tunnel_vision_" -- Fallback to default texture
  local texturePath = 'Interface\\AddOns\\UltraHardcore\\textures\\' .. texturePrefix .. string.format(blurIntensity) .. '.png'
  
  frame.texture:SetTexture(texturePath)
  frame:SetAlpha(0)
  frame:Show()

  -- Smooth fade in
  local fadeDuration = 0.5 -- Fade in duration for new overlays
  UIFrameFadeIn(frame, fadeDuration, 0, 1)
end
