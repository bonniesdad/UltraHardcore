function GetCurrentResourceType()
  local _, playerClass = UnitClass('player')
  local form = GetShapeshiftFormID()
  -- Aquatic Form - 4
  -- Bear Form - 5 (BEAR_FORM constant)
  -- Cat Form - 1 (CAT_FORM constant)
  -- Flight Form - 29
  -- Moonkin Form - 31 - 35 (MOONKIN_FORM constant) (different races seem to have different numbers)
  -- Swift Flight Form - 27
  -- Travel Form - 3
  -- Tree of Life - 2
  -- Treant Form - 36
  if playerClass == 'ROGUE' or (playerClass == 'DRUID' and form == 1) then
    return 'ENERGY'
  elseif playerClass == 'WARRIOR' or (playerClass == 'DRUID' and (form == 5)) then
    return 'RAGE'
  end
  return 'MANA'
end
