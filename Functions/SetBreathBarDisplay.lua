-- 🟢 Function to hide/show the default breath bar
function SetBreathBarDisplay(hideBreathBar)
  if hideBreathBar then
    -- Hide the breath bar by hiding the mirror bar frames
    if MirrorTimer1 then
      ForceHideFrame(MirrorTimer1)
    end
    if MirrorTimer2 then
      ForceHideFrame(MirrorTimer2)
    end
    if MirrorTimer3 then
      ForceHideFrame(MirrorTimer3)
    end
    
    -- Also hide any existing breath bar frames
    if PlayerBreathMeter then
      ForceHideFrame(PlayerBreathMeter)
    end
    if PlayerBreathMeterFrame then
      ForceHideFrame(PlayerBreathMeterFrame)
    end
  else
    -- Restore breath bar frames
    if MirrorTimer1 then
      RestoreAndShowFrame(MirrorTimer1)
    end
    if MirrorTimer2 then
      RestoreAndShowFrame(MirrorTimer2)
    end
    if MirrorTimer3 then
      RestoreAndShowFrame(MirrorTimer3)
    end
    if PlayerBreathMeter then
      RestoreAndShowFrame(PlayerBreathMeter)
    end
    if PlayerBreathMeterFrame then
      RestoreAndShowFrame(PlayerBreathMeterFrame)
    end
  end
end
