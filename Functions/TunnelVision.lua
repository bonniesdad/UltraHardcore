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
    local shouldShow4 = healthPercent <= 20
    local shouldShow3 = healthPercent <= 40
    local shouldShow2 = healthPercent <= 60
    local shouldShow1 = healthPercent <= 80

    -- Determine which overlays were active based on previous health
    local wasShowing4 = previousHealthPercent <= 20
    local wasShowing3 = previousHealthPercent <= 40
    local wasShowing2 = previousHealthPercent <= 60
    local wasShowing1 = previousHealthPercent <= 80

    -- Remove overlays that should no longer be shown (health went up)
    if wasShowing4 and not shouldShow4 then
      RemoveSpecificTunnelVision(4)
    end
    if wasShowing3 and not shouldShow3 then
      RemoveSpecificTunnelVision(3)
    end
    if wasShowing2 and not shouldShow2 then
      RemoveSpecificTunnelVision(2)
    end
    if wasShowing1 and not shouldShow1 then
      RemoveSpecificTunnelVision(1)
    end

    -- Show overlays that should be active but aren't yet (health went down)
    if shouldShow4 and not wasShowing4 then
      ShowTunnelVision(4)
    end
    if shouldShow3 and not wasShowing3 then
      ShowTunnelVision(3)
    end
    if shouldShow2 and not wasShowing2 then
      ShowTunnelVision(2)
    end
    if shouldShow1 and not wasShowing1 then
      ShowTunnelVision(1)
    end

    -- Update previous health for next comparison
    previousHealthPercent = healthPercent
  else
    RemoveTunnelVision()
    previousHealthPercent = 100
  end
end