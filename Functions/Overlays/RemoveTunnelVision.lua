-- Function to remove a specific tunnel vision overlay with fade out
function RemoveSpecificTunnelVision(blurIntensity)
  local frameName = 'UltraHardcoreTunnelVision_' .. blurIntensity
  
  if UltraHardcore.tunnelVisionFrames and UltraHardcore.tunnelVisionFrames[frameName] then
    local frame = UltraHardcore.tunnelVisionFrames[frameName]
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
  if UltraHardcore.tunnelVisionFrames then
    for frameName, frame in pairs(UltraHardcore.tunnelVisionFrames) do
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
  if UltraHardcore.tunnelVisionFrame then
    if UltraHardcore.tunnelVisionFrame:IsShown() and UltraHardcore.tunnelVisionFrame:GetAlpha() > 0 then
      UIFrameFadeOut(UltraHardcore.tunnelVisionFrame, fadeDuration, UltraHardcore.tunnelVisionFrame:GetAlpha(), 0)
      C_Timer.After(fadeDuration + 0.1, function()
        UltraHardcore.tunnelVisionFrame:Hide()
      end)
    end
  end

  if UltraHardcore.backupTunnelVisionFrame then
    if UltraHardcore.backupTunnelVisionFrame:IsShown() and UltraHardcore.backupTunnelVisionFrame:GetAlpha() > 0 then
      UIFrameFadeOut(UltraHardcore.backupTunnelVisionFrame, fadeDuration, UltraHardcore.backupTunnelVisionFrame:GetAlpha(), 0)
      C_Timer.After(fadeDuration + 0.1, function()
        UltraHardcore.backupTunnelVisionFrame:Hide()
      end)
    end
  end
end
