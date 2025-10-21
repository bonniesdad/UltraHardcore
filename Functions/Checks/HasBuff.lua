local function hasBuffWithSpellIdOrName(unit, expectedSpellId, expectedName)
  for i = 1, 40 do
    local name, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
    if not name then break end
    if spellId == expectedSpellId or name == expectedName then
      return true
    end
  end
  return false
end


function HasCozyFire()
    return hasBuffWithSpellIdOrName("player", 7353, "Cozy Fire")
end

