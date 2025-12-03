-- Function to remove a specific tunnel vision overlay with fade out
function RemoveSpecificTunnelVision(blurIntensity)
  local frameName = 'UltraHardcoreTunnelVision_' .. blurIntensity
  
  if Ultra.tunnelVisionFrames and Ultra.tunnelVisionFrames[frameName] then
    local frame = Ultra.tunnelVisionFrames[frameName]
    if frame and frame:IsShown() and frame:GetAlpha() > 0 then
      local fadeDuration = 0.5 -- Match the fade duration from ShowTunnelVision
      UIFrameFadeOut(frame, fadeDuration, frame:GetAlpha(), 0)
      C_Timer.After(fadeDuration + 0.1, function()
        if frame:GetAlpha() == 0 then
          frame:Hide()
        end
      end)
    end
  end
end

function RemoveTunnelVision()
  local fadeDuration = 0.5 -- Match the fade duration from ShowTunnelVision
  
  -- Remove all stacked tunnel vision frames with fade out
  if Ultra.tunnelVisionFrames then
    for frameName, frame in pairs(Ultra.tunnelVisionFrames) do
      if frame and frame:IsShown() and frame:GetAlpha() > 0 then
        UIFrameFadeOut(frame, fadeDuration, frame:GetAlpha(), 0)
        C_Timer.After(fadeDuration + 0.1, function()
          if frame:GetAlpha() == 0 then
            frame:Hide()
          end
        end)
      end
    end
  end
  
  -- Legacy support for old frame system (in case it exists)
  if Ultra.tunnelVisionFrame then
    if Ultra.tunnelVisionFrame:IsShown() and Ultra.tunnelVisionFrame:GetAlpha() > 0 then
      UIFrameFadeOut(Ultra.tunnelVisionFrame, fadeDuration, Ultra.tunnelVisionFrame:GetAlpha(), 0)
      C_Timer.After(fadeDuration + 0.1, function()
        Ultra.tunnelVisionFrame:Hide()
      end)
    end
  end

  if Ultra.backupTunnelVisionFrame then
    if Ultra.backupTunnelVisionFrame:IsShown() and Ultra.backupTunnelVisionFrame:GetAlpha() > 0 then
      UIFrameFadeOut(Ultra.backupTunnelVisionFrame, fadeDuration, Ultra.backupTunnelVisionFrame:GetAlpha(), 0)
      C_Timer.After(fadeDuration + 0.1, function()
        Ultra.backupTunnelVisionFrame:Hide()
      end)
    end
  end
end
