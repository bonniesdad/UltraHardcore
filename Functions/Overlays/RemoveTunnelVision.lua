function RemoveTunnelVision()
  if UltraHardcore.tunnelVisionFrame then
    if UltraHardcore.tunnelVisionFrame:IsShown() then
      UIFrameFadeOut(UltraHardcore.tunnelVisionFrame, 1, 1, 0) -- Fade out tunnelVisionFrame
      C_Timer.After(1, function()
        UltraHardcore.tunnelVisionFrame:Hide() -- Hide the blur effect
      end)
      lastCalledBlurIntensity = 0
    end

    if UltraHardcore.backupTunnelVisionFrame:IsShown() then
      UIFrameFadeOut(UltraHardcore.backupTunnelVisionFrame, 1, 1, 0) -- Fade out backupTunnelVisionFrame
      C_Timer.After(1, function()
        UltraHardcore.backupTunnelVisionFrame:Hide() -- Hide the blur effect
      end)
      lastCalledBlurIntensity = 0
    end
  end
end
