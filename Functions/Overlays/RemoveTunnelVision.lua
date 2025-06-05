function RemoveTunnelVision()
  if UltraHardcore.tunnelVisionFrame then
    if UltraHardcore.tunnelVisionFrame:IsShown() then
      UIFrameFadeOut(UltraHardcore.tunnelVisionFrame, 1, 1, 0) -- Fade out backupDeathIndicatorFrame
      C_Timer.After(1, function()
        UltraHardcore.tunnelVisionFrame:Hide() -- Hide the blur effect
      end)
      lastCalledBlurIntensity = 0
    end

    if UltraHardcore.backupDeathIndicatorFrame:IsShown() then
      UIFrameFadeOut(UltraHardcore.backupDeathIndicatorFrame, 1, 1, 0) -- Fade out backupDeathIndicatorFrame
      C_Timer.After(1, function()
        UltraHardcore.backupDeathIndicatorFrame:Hide() -- Hide the blur effect
      end)
      lastCalledBlurIntensity = 0
    end
  end
end
