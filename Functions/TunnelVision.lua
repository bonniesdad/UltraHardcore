-- Track previous health percentage to detect increases
local previousHealthPercent = 100

function TunnelVision(self, event, unit, showTunnelVision)
  if showTunnelVision then
    local healthPercent = (UnitHealth('player') / UnitHealthMax('player')) * 100

    if UnitIsDeadOrGhost('player') then
      RemoveTunnelVision()
      previousHealthPercent = healthPercent
      return
    end

    -- Only remove overlays if health is above 80%
    if healthPercent > 80 then
      RemoveTunnelVision()
      previousHealthPercent = healthPercent
      return
    end

    if healthPercent == 0 or healthPercent == nil then
      RemoveTunnelVision()
      previousHealthPercent = healthPercent
      return
    end

    -- Determine which overlays should be active based on current health
    local shouldShow19 = healthPercent <= 20
    local shouldShow14 = healthPercent <= 40
    local shouldShow9 = healthPercent <= 60
    local shouldShow4 = healthPercent <= 80

    -- Determine which overlays were active based on previous health
    local wasShowing19 = previousHealthPercent <= 20
    local wasShowing14 = previousHealthPercent <= 40
    local wasShowing9 = previousHealthPercent <= 60
    local wasShowing4 = previousHealthPercent <= 80

    -- Remove overlays that should no longer be shown (health went up)
    if wasShowing19 and not shouldShow19 then
      RemoveSpecificTunnelVision(19)
    end
    if wasShowing14 and not shouldShow14 then
      RemoveSpecificTunnelVision(14)
    end
    if wasShowing9 and not shouldShow9 then
      RemoveSpecificTunnelVision(9)
    end
    if wasShowing4 and not shouldShow4 then
      RemoveSpecificTunnelVision(4)
    end

    -- Show overlays that should be active but aren't yet (health went down)
    if shouldShow19 and not wasShowing19 then
      ShowTunnelVision(19)
    end
    if shouldShow14 and not wasShowing14 then
      ShowTunnelVision(14)
    end
    if shouldShow9 and not wasShowing9 then
      ShowTunnelVision(9)
    end
    if shouldShow4 and not wasShowing4 then
      ShowTunnelVision(4)
    end

    -- Update previous health for next comparison
    previousHealthPercent = healthPercent
  else
    RemoveTunnelVision()
    previousHealthPercent = 100
  end
end
