-- 🟢 Track lowest health percentage
function TrackLowestHealth()
  local health = UnitHealth('player')
  local maxHealth = UnitHealthMax('player')
  local healthPercent = (health / maxHealth) * 100

  if healthPercent < lowestHealthScore then
    lowestHealthScore = healthPercent
    SaveDBData('lowestHealthScore', lowestHealthScore)
  end
end

-- Register the health tracking event
local frame = CreateFrame('Frame')
frame:RegisterEvent('UNIT_HEALTH')
frame:SetScript('OnEvent', function(self, event, unit)
  if unit == 'player' then
    TrackLowestHealth()
  end
end) 