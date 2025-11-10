-- 🟢 Function to hide/show the default breath bar
function SetBreathBarDisplay(hideBreathBar)
  if hideBreathBar then
    -- Only hide legacy/alternate breath frames; keep MirrorTimer frames intact so fatigue shows
    if PlayerBreathMeter then
      ForceHideFrame(PlayerBreathMeter)
    end
    if PlayerBreathMeterFrame then
      ForceHideFrame(PlayerBreathMeterFrame)
    end
  else
    if PlayerBreathMeter then
      RestoreAndShowFrame(PlayerBreathMeter)
    end
    if PlayerBreathMeterFrame then
      RestoreAndShowFrame(PlayerBreathMeterFrame)
    end
  end
end
