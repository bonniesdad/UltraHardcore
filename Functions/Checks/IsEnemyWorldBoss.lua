function IsEnemyWorldBoss(unitGUID)
  -- Check if the killed enemy is currently our target
  if UnitGUID('target') == unitGUID then
    local classification = UnitClassification('target')
    if classification == 'worldboss' then
      return true
    end
  end
  
  -- Check if the killed enemy is a party member's target
  for i = 1, GetNumGroupMembers() do
    local unitID = "party" .. i .. "target"
    if UnitGUID(unitID) == unitGUID then
      local classification = UnitClassification(unitID)
      if classification == 'worldboss' then
        return true
      end
    end
  end
  
  return false
end
