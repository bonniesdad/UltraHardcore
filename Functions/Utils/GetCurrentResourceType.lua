function GetCurrentResourceType()
  local _, playerClass = UnitClass('player')
  local form = GetShapeshiftFormID()
  -- 1 for Cat Form
  -- 5 for Bear Form
  -- 31 for Dire Bear Form
  -- 3 for Travel Form
  -- 4 for Aquatic Form
  if playerClass == 'ROGUE' or (playerClass == 'DRUID' and form == 1) then
    return 'ENERGY'
  elseif playerClass == 'WARRIOR' or (playerClass == 'DRUID' and (form == 5 or form == 31)) then
    return 'RAGE'
  end
  return 'MANA'
end
