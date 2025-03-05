function RemoveDeathIndicator()
  if UltraHardcore.deathIndicatorFrame then
    if UltraHardcore.deathIndicatorFrame:IsShown() then
      UIFrameFadeOut(UltraHardcore.deathIndicatorFrame, 1, 1, 0) -- Fade out backupDeathIndicatorFrame
      C_Timer.After(1, function()
        UltraHardcore.deathIndicatorFrame:Hide() -- Hide the blur effect
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
