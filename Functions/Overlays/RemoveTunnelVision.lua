function RemoveTunnelVision()
  if UltraHardcore.tunnelVisionFrame then
    local fadeDuration = 0.8 -- Match the fade duration from ShowTunnelVision
    
    -- Fade out whichever frame is currently visible
    if UltraHardcore.tunnelVisionFrame:IsShown() and UltraHardcore.tunnelVisionFrame:GetAlpha() > 0 then
      UIFrameFadeOut(UltraHardcore.tunnelVisionFrame, fadeDuration, UltraHardcore.tunnelVisionFrame:GetAlpha(), 0)
      C_Timer.After(fadeDuration + 0.1, function()
        UltraHardcore.tunnelVisionFrame:Hide()
      end)
    end

    if UltraHardcore.backupTunnelVisionFrame:IsShown() and UltraHardcore.backupTunnelVisionFrame:GetAlpha() > 0 then
      UIFrameFadeOut(UltraHardcore.backupTunnelVisionFrame, fadeDuration, UltraHardcore.backupTunnelVisionFrame:GetAlpha(), 0)
      C_Timer.After(fadeDuration + 0.1, function()
        UltraHardcore.backupTunnelVisionFrame:Hide()
      end)
    end
    
    lastCalledBlurIntensity = 0
  end
end
