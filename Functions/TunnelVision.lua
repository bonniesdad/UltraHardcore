function TunnelVision(self, event, unit, showTunnelVision)
  if showTunnelVision then
    local healthPercent = (UnitHealth('player') / UnitHealthMax('player')) * 100
    if healthPercent <= 20 then
      ShowtunnelVision(19)
    elseif healthPercent <= 40 then
      ShowtunnelVision(14)
    elseif healthPercent <= 60 then
      ShowtunnelVision(9)
    elseif healthPercent <= 80 then
      ShowtunnelVision(4)
    else
      RemoveTunnelVision()
    end
  else
    RemoveTunnelVision()
  end
end
