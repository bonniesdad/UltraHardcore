function DeathIndicator(self, event, unit, showTunnelVision)
  if showTunnelVision then
    local healthPercent = (UnitHealth('player') / UnitHealthMax('player')) * 100
    if healthPercent <= 20 then
      ApplyDeathIndicatorChange(19)
    elseif healthPercent <= 40 then
      ApplyDeathIndicatorChange(14)
    elseif healthPercent <= 60 then
      ApplyDeathIndicatorChange(9)
    elseif healthPercent <= 80 then
      ApplyDeathIndicatorChange(4)
    else
      RemoveDeathIndicator()
    end
  else
    RemoveDeathIndicator()
  end
end
