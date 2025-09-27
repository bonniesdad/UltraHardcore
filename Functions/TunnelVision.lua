function TunnelVision(self, event, unit, showTunnelVision)
  if showTunnelVision then
    local healthPercent = (UnitHealth('player') / UnitHealthMax('player')) * 100
    if healthPercent <= 0 then
      RemoveTunnelVision()
    elseif healthPercent <= 20 then
      ShowTunnelVision(19)
    elseif healthPercent <= 40 then
      ShowTunnelVision(14)
    elseif healthPercent <= 60 then
      ShowTunnelVision(9)
    elseif healthPercent <= 80 then
      ShowTunnelVision(4)
    else
      RemoveTunnelVision()
    end
  else
    RemoveTunnelVision()
  end
end
