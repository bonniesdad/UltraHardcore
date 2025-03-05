function IsEnemyElite(unitGUID)
  local classification = UnitClassification(unitGUID)
  if classification == 'elite' then
    return true
  end

  return false
end
